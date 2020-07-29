import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart' show required;

class Place {
  final String id, title, vicinity;
  final LatLng position;

  Place(
      {@required this.id,
      @required this.title,
      @required this.position,
      this.vicinity = ''});

  static Place fromJson(Map<String, dynamic> json) {
    final coords = List<double>.from(json['position']);

    return Place(
      id: json['id'],
      title: json['title'],
      vicinity: json['vicinity'] != null ? json['vicinity'] : '',
      position: LatLng(coords[0], coords[1]),
    );
  }
}
