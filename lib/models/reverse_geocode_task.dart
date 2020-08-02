import 'package:equatable/equatable.dart';
import 'package:google_maps/models/place.dart';
import 'package:meta/meta.dart' show required;

class ReverseGeocodeTask extends Equatable {
  final Place place;
  final bool isOrigin;
  ReverseGeocodeTask({this.place, @required this.isOrigin});

  ReverseGeocodeTask copyWith({
    Place place,
    bool isOrigin,
  }) {
    return ReverseGeocodeTask(
      place: place ?? this.place,
      isOrigin: isOrigin ?? this.isOrigin,
    );
  }

  @override
  List<Object> get props => [
        place,
        isOrigin,
      ];
}
