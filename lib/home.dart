import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mitril_play/backend/settings_service.dart';
import 'package:mitril_play/backend/sql.dart';
import 'package:mitril_play/backend/utils.dart';
import 'package:mitril_play/bottom_nav.dart';
import 'package:mitril_play/channel_tile.dart';
import 'package:mitril_play/loading.dart';
import 'package:mitril_play/models/channel.dart';
import 'package:mitril_play/models/filters.dart';
import 'package:mitril_play/models/home_manager.dart';
import 'package:mitril_play/models/media_type.dart';
import 'package:mitril_play/models/no_push_animation_material_page_route.dart';
import 'package:mitril_play/models/node.dart';
import 'package:mitril_play/models/node_type.dart';
import 'package:mitril_play/models/source.dart';
import 'package:mitril_play/models/source_type.dart';
import 'package:mitril_play/models/view_type.dart';
import 'package:mitril_play/error.dart';
import 'package:mitril_play/whats_new_modal.dart';

class Home extends StatefulWidget {
  final HomeManager home;
  final bool refresh;
  final firstLaunch;
  const Home(
      {super.key,
      required this.home,
      this.refresh = false,
      this.firstLaunch = false});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _debounce;
  bool reachedMax = false;
  final int pageSize = 36;
  List<Channel> channels = [];
  Map<int, String> sourceNames = {}; // Cache de nomes das sources
  List<Source> allSources = []; // Todas as fontes disponíveis
  Set<int> selectedSourceIds = {}; // Fontes selecionadas (vazio = todas)
  bool searchMode = false;
  final FocusNode _focusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool blockSettings = false;
  int? previousScroll;
  MediaType? _selectedMediaType; // Filtro de tipo de mídia

  Future<String> _getSourceName(int sourceId) async {
    if (sourceNames.containsKey(sourceId)) {
      return sourceNames[sourceId]!;
    }
    try {
      final source = await Sql.getSourceFromId(sourceId);
      sourceNames[sourceId] = source.name;
      return source.name;
    } catch (e) {
      return 'Lista $sourceId';
    }
  }

  Future<void> _loadSources() async {
    try {
      final sources = await Sql.getSources();
      setState(() {
        allSources = sources.where((s) => s.enabled).toList();
      });
    } catch (e) {
      // Ignorar erro silenciosamente
    }
  }

  void _showSourceFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrar por Listas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Opção para selecionar todas
                  ListTile(
                    leading: Icon(
                      selectedSourceIds.isEmpty
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selectedSourceIds.isEmpty
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: const Text('Todas as listas'),
                    trailing: Switch(
                      value: selectedSourceIds.isEmpty,
                      onChanged: (_) {
                        setState(() {
                          selectedSourceIds.clear();
                        });
                        setModalState(() {});
                      },
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Selecione uma ou mais listas para filtrar:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Lista de fontes com switches
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allSources.length,
                      itemBuilder: (context, index) {
                        final source = allSources[index];
                        final isSelected = selectedSourceIds.isEmpty
                            ? true
                            : selectedSourceIds.contains(source.id);
                        return ListTile(
                          leading: Icon(
                            Icons.list_alt,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          title: Text(source.name),
                          subtitle: Text(
                            getSourceTypeString(source.sourceType),
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Switch(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  selectedSourceIds.add(source.id!);
                                } else {
                                  selectedSourceIds.remove(source.id);
                                }
                              });
                              setModalState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Botão aplicar
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applySourceFilter();
                    },
                    child: Text(
                      selectedSourceIds.isEmpty
                          ? 'Mostrar todas as listas'
                          : 'Mostrar ${selectedSourceIds.length} lista(s)',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applySourceFilter() {
    // Atualizar os filtros com as fontes selecionadas
    if (selectedSourceIds.isEmpty) {
      // Se nenhuma selecionada, usa todas
      widget.home.filters.sourceIds = allSources.map((s) => s.id!).toList();
    } else {
      widget.home.filters.sourceIds = selectedSourceIds.toList();
    }
    
    // Salvar seleção para persistência
    SettingsService.saveSelectedSourceIds(selectedSourceIds.toList());
    
    _scrollController.jumpTo(0);
    load(false);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    initializeAsync();
  }

  Future<void> initializeAsync() async {
    await _loadSources();
    
    // Carregar seleção de fontes persistida
    final savedSourceIds = await SettingsService.getSelectedSourceIds();
    
    if (widget.home.filters.sourceIds == null) {
      if (savedSourceIds.isNotEmpty) {
        // Usar seleção persistida
        selectedSourceIds = savedSourceIds.toSet();
        widget.home.filters.sourceIds = savedSourceIds;
      } else {
        // Usar todas as fontes
        final sources = await Sql.getEnabledSourcesMinimal();
        widget.home.filters.sourceIds = sources.map((x) => x.id).toList();
      }
    } else {
      // Inicializar selectedSourceIds com base nos filtros existentes
      selectedSourceIds = widget.home.filters.sourceIds!.toSet();
    }
    if (widget.home.filters.mediaTypes == null) {
      widget.home.filters.mediaTypes =
          (await SettingsService.getSettings()).getMediaTypes();
    }
    // Inicializar filtro de tipo de mídia
    _selectedMediaType = null;
    await load();
    final String? version = await SettingsService.shouldShowWhatsNew();
    if (widget.firstLaunch && version != null) {
      await showWhatsNew(version);
    }
    if (widget.refresh) {
      Error.tryAsyncNoLoading(() async {
        setState(() {
          blockSettings = true;
        });
        await Utils.refreshAllSources();
      }, context, true, "Refreshed all sources");
      setState(() {
        blockSettings = false;
      });
    }
  }

  Future<void> showWhatsNew(String version) async {
    showDialog(
        context: context,
        builder: (context) => WhatsNewModal(version: version));
  }

  void toggleSearch() {
    setState(() {
      searchMode = !searchMode;
    });
    if (searchMode) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_focusNode));
    } else {
      FocusScope.of(context).unfocus();
      widget.home.filters.query = null;
      searchController.clear();
      _scrollController.jumpTo(0);
      load(false);
    }
  }

  void toggleMediaType(MediaType? type) {
    setState(() {
      _selectedMediaType = _selectedMediaType == type ? null : type;
      widget.home.filters.mediaTypes = _selectedMediaType != null
          ? [ _selectedMediaType! ]
          : (MediaType.values.toList()..remove(MediaType.group));
    });
    _scrollController.jumpTo(0);
    load(false);
  }

  Widget _buildMediaTypeButton({
    required IconData icon,
    required String label,
    required MediaType mediaType,
  }) {
    final isSelected = _selectedMediaType == mediaType;
    return ElevatedButton.icon(
      onPressed: () => toggleMediaType(mediaType),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> load([bool more = false]) async {
    if (more) {
      widget.home.filters.page++;
    } else {
      widget.home.filters.page = 1;
    }
    await Error.tryAsyncNoLoading(() async {
      List<Channel> channels = await Sql.search(widget.home.filters);
      if (!more) {
        setState(() {
          this.channels = channels;
        });
        // Carregar nomes das sources
        final uniqueSourceIds = channels.map((c) => c.sourceId).toSet();
        for (final sourceId in uniqueSourceIds) {
          if (!sourceNames.containsKey(sourceId)) {
            await _getSourceName(sourceId);
          }
        }
      } else {
        setState(() {
          this.channels.addAll(channels);
        });
        // Carregar nomes das sources dos novos canais
        final uniqueSourceIds = channels.map((c) => c.sourceId).toSet();
        for (final sourceId in uniqueSourceIds) {
          if (!sourceNames.containsKey(sourceId)) {
            await _getSourceName(sourceId);
          }
        }
      }
      reachedMax = channels.length < pageSize;
    }, context);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() async {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.75 &&
        !isLoading &&
        !reachedMax) {
      setState(() {
        isLoading = true;
      });
      await load(true);
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleBack() {
    toggleSearch();
  }

  bool canPop() {
    return !searchMode;
  }

  void clearSearch() {
    widget.home.filters.query = null;
    searchController.clear();
  }

  ViewType getStartingView() {
    if (widget.home.filters.groupId != null) {
      return ViewType.categories;
    }
    return widget.home.filters.viewType;
  }

  void updateViewMode(ViewType type) {
    Navigator.of(context).pushAndRemoveUntil(
        NoPushAnimationMaterialPageRoute(
            builder: (context) => Home(
                home: HomeManager(
                    filters: Filters(
                        viewType: type,
                        mediaTypes: widget.home.filters.mediaTypes,
                        sourceIds: widget.home.filters.sourceIds)))),
        (route) => false);
  }

  void setNode(Node node) {
    final home = HomeManager(
        node: node,
        filters: Filters(
            viewType: ViewType.all,
            mediaTypes: widget.home.filters.mediaTypes,
            sourceIds: widget.home.filters.sourceIds));
    if (widget.home.filters.groupId != null) {
      home.filters.groupId = widget.home.filters.groupId;
    } else if (node.type == NodeType.category) {
      home.filters.groupId = node.id;
    }
    if (node.type == NodeType.series) home.filters.seriesId = node.id;
    Navigator.of(context).push(NoPushAnimationMaterialPageRoute(
        builder: (context) => Home(home: home)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: canPop(),
        onPopInvokedWithResult: (didPop, result) {
          handleBack();
        },
        child: Scaffold(
            appBar: widget.home.node != null
                ? AppBar(
                    title: Text(widget.home.node.toString()),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                : null,
            body: Loading(
                child: SafeArea(
                    child: Column(children: [
              AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: searchMode
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainer, // Background color
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                controller: searchController,
                                focusNode: _focusNode,
                                onChanged: (query) {
                                  _debounce?.cancel();
                                  _debounce = Timer(
                                      const Duration(milliseconds: 500), () {
                                    widget.home.filters.query = query;
                                    load(false);
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        widget.home.filters.useKeywords =
                                            !widget.home.filters.useKeywords;
                                        load(false);
                                      },
                                      icon: Icon(widget.home.filters.useKeywords
                                          ? Icons.label
                                          : Icons.label_outline)),
                                  filled: true, // Light background for contrast
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                ),
                              )),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 40,
                                  child: IconButton(
                                      onPressed: toggleSearch,
                                      icon: const Icon(
                                        Icons.close,
                                      )))
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
              // Filtros de tipo de mídia (TV, Filmes, Séries)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMediaTypeButton(
                      icon: Icons.live_tv,
                      label: 'TV',
                      mediaType: MediaType.livestream,
                    ),
                    const SizedBox(width: 12),
                    _buildMediaTypeButton(
                      icon: Icons.movie,
                      label: 'Filmes',
                      mediaType: MediaType.movie,
                    ),
                    const SizedBox(width: 12),
                    _buildMediaTypeButton(
                      icon: Icons.video_library,
                      label: 'Séries',
                      mediaType: MediaType.serie,
                    ),
                    const SizedBox(width: 16),
                    // Botão de filtro por listas
                    ElevatedButton.icon(
                      onPressed: _showSourceFilter,
                      icon: Icon(
                        selectedSourceIds.isEmpty || 
                        selectedSourceIds.length == allSources.length
                            ? Icons.list_alt
                            : Icons.filter_list,
                        size: 20,
                      ),
                      label: Text(
                        selectedSourceIds.isEmpty || 
                        selectedSourceIds.length == allSources.length
                            ? 'Todas'
                            : '${selectedSourceIds.length}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedSourceIds.isEmpty || 
                        selectedSourceIds.length == allSources.length
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: selectedSourceIds.isEmpty || 
                        selectedSourceIds.length == allSources.length
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: GridView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
                itemCount: channels.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 220,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  final sourceName = sourceNames[channel.sourceId] ?? 'Lista';
                  return ChannelTile(
                    channel: channel,
                    parentContext: context,
                    setNode: setNode,
                    groupName: sourceName,
                  );
                },
              )),
            ]))),
            bottomNavigationBar: BottomNav(
              startingView: getStartingView(),
              blockSettings: blockSettings,
              updateViewMode: updateViewMode,
            ),
            floatingActionButton: Visibility(
              visible: !searchMode,
              child: FloatingActionButton(
                onPressed: toggleSearch,
                tooltip: 'Search',
                child: const Icon(Icons.search),
              ),
            )));
  }
}
