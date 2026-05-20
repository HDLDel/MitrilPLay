import 'package:mitril_play/models/exceptions/invalid_value_exception.dart';
import 'package:mitril_play/models/media_type.dart';

enum NodeType { category, series, season }

NodeType fromMediaType(MediaType type) {
  switch (type) {
    case MediaType.group:
      return NodeType.category;
    case MediaType.serie:
      return NodeType.series;
    case MediaType.season:
      return NodeType.season;
    case MediaType.livestream:
      throw InvalidValueException(MediaType.livestream.toString());
    case MediaType.movie:
      throw InvalidValueException(MediaType.livestream.toString());
  }
}
