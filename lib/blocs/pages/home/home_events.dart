import 'package:google_maps/blocs/pages/home/home_state.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/models/reverse_geocode_task.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import '../../../models/place.dart';

abstract class HomeEvents {}

class OnMyLocationUpdate extends HomeEvents {
  final LatLng location;
  OnMyLocationUpdate(this.location);
}

class OnMapTap extends HomeEvents {
  final LatLng location;
  OnMapTap(this.location);
}

class GoToPlace extends HomeEvents {
  final Place place;
  GoToPlace(this.place);
}

class OnGpsEnabled extends HomeEvents {
  final bool enabled;

  OnGpsEnabled(this.enabled);
}

class ConfirmPoint extends HomeEvents {
  final Place place;
  final bool isOrigin;
  ConfirmPoint(this.place, this.isOrigin);
}

class OnMapPick extends HomeEvents {
  final MapPick pick;
  OnMapPick(this.pick);
}

class AddReverseGeocodeTask extends HomeEvents {
  final ReverseGeocodeTask task;
  AddReverseGeocodeTask(this.task);
}

class FinishReverseGeocodeTask extends HomeEvents {
  final Place place;
  FinishReverseGeocodeTask(this.place);
}
