import 'package:meta/meta.dart' show required;

class Route {
  final String id;
  final DateTime arrivalTime;
  final int duration, length;
  final String polyline;

  Route({
    @required this.id,
    @required this.arrivalTime,
    @required this.duration,
    @required this.length,
    @required this.polyline,
  });

  static Route fromJson(Map<String, dynamic> json) {
    final section = Map<String, dynamic>.from(json['sections'][0]);

    return Route(
      id: json['id'],
      arrivalTime: DateTime.parse(section['arrival']['time']),
      duration: section['summary']['duration'],
      length: section['summary']['length'],
      polyline: section['polyline'],
    );
  }
}
