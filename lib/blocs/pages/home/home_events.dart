import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

abstract class HomeEvents {}

class OnMyLocationUpdate extends HomeEvents {
  final LatLng location;
  OnMyLocationUpdate(this.location);
}

class OnMapTap extends HomeEvents {
  final LatLng location;
  OnMapTap(this.location);
}

class OnGpsEnabled extends HomeEvents {
  final bool enabled;

  OnGpsEnabled(this.enabled);
}
