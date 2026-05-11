import 'package:flutter/material.dart';
import 'package:mitril_play/backend/settings_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsNewModal extends StatelessWidget {
  final String version;
  const WhatsNewModal({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("What's new: update $version"),
        actions: [
          TextButton(
              onPressed: () async {
                await launchUrl(
                    Uri.parse(
                      "https://github.com/Fredolx/open-tv-mobile/discussions/1",
                    ),
                    mode: LaunchMode.externalApplication);
                Navigator.pop(context, false);
              },
              child: const Text("Donate")),
          TextButton(
              onPressed: () async {
                await SettingsService.updateLastSeenVersion();
                Navigator.pop(context, true);
              },
              child: const Text("Don't show again"))
        ],
        content: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
              child: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: const Text(
                    '''
Hi! Thanks for supporting MitrilPlay. Here's everything new:

- Fixed some streams not playing by adding support for HTTP headers. Some streams may still not play; I am actively working on it. Please open an issue on GitHub if you are experiencing playback issues.
- Added aspect ratio button for filling the entire screen
- Added media type filtering for categories

If you like MitrilPlay, please consider donating (Even a dollar helps tremendously), reporting issues on the github and sharing it with your friends.
''',
                  ))),
        ));
  }
}
