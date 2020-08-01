import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/blocs/pages/home/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/pages/origin_and_destination_page.dart';
import 'package:google_maps/utils/extras.dart';
import 'package:google_maps/utils/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'bloc.dart';
import 'home_events.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvents, HomeState> {
  Geolocator _geolocator = Geolocator();
  final LocationPermissions _locationPermissions = LocationPermissions();
  Completer<GoogleMapController> _completer = Completer();

  final LocationOptions _locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  StreamSubscription<Position> _subscription;
  StreamSubscription<ServiceStatus> _subscriptionGpsStatus;

  Future<GoogleMapController> get _mapController async {
    return await _completer.future;
  }

  HomeBloc() {
    this._init();
  }

  @override
  Future<void> close() async {
    _subscription?.cancel();
    _subscriptionGpsStatus?.cancel();
    super.close();
  }

  static HomeBloc of(BuildContext context) =>
      BlocProvider.of<HomeBloc>(context);

  _init() async {
    _subscription = _geolocator.getPositionStream(_locationOptions).listen(
      (Position position) async {
        if (position != null) {
          final newPosition = LatLng(position.latitude, position.longitude);
          add(
            OnMyLocationUpdate(
              newPosition,
            ),
          );
        }
      },
    );

    if (Platform.isAndroid) {
      _subscriptionGpsStatus =
          _locationPermissions.serviceStatus.listen((status) {
        add(
          OnGpsEnabled(status == ServiceStatus.enabled),
        );
      });
    }
  }

  goToMyPosition() async {
    if (this.state.myLocation != null) {
      final CameraUpdate cameraUpdate =
          CameraUpdate.newLatLng(this.state.myLocation);
      await (await _mapController).moveCamera(cameraUpdate);
    }
  }

  whereYouGo(BuildContext context) async {
    final List<Place> history = this.state.history.values.toList();
    final route = MaterialPageRoute<Place>(
      builder: (_) => OriginAndDestinationPage(
        origin: this.state.origin,
        destination: this.state.destination,
        history: history,
        onOriginChanged: (Place origin) {
          add(
            ConfirmPoint(origin, true),
          );
        },
      ),
      fullscreenDialog: true,
    );
    final Place itemSelected = await Navigator.push(context, route);
    if (itemSelected != null) {
      add(ConfirmPoint(itemSelected, false));
    }
  }

  void setMapController(GoogleMapController controller) {
    if (_completer.isCompleted) {
      _completer = Completer();
    }
    controller.setMapStyle(jsonEncode(mapStyle));
    _completer.complete(controller);
  }

  @override
  HomeState get initialState => HomeState.initialState;

  @override
  Stream<HomeState> mapEventToState(HomeEvents event) async* {
    if (event is OnMyLocationUpdate) {
      yield* this._mapOnMyLocationUpdate(event);
    } else if (event is OnGpsEnabled) {
      yield this.state.copyWith(gpsEnabled: event.enabled);
    } else if (event is ConfirmPoint) {
      yield* this._mapConfirmPoint(event);
    }
  }

  Stream<HomeState> _mapConfirmPoint(ConfirmPoint event) async* {
    final Place origin = event.isOrigin ? event.place : this.state.origin;
    final Place destination =
        !event.isOrigin ? event.place : this.state.destination;

    final markers = Map<MarkerId, Marker>.from(this.state.markers);

    final history = Map<String, Place>.from(this.state.history);
    history[event.place.id] = event.place;

    CameraUpdate cameraUpdate;

    Map<PolylineId, Polyline> polylines;

    if (origin != null && destination != null) {
      cameraUpdate = centerMap(
        origin.position,
        destination.position,
        padding: 80,
      );
      final routeData = await createRoute(
        polylines: this.state.polylines,
        origin: origin.position,
        destination: destination.position,
      );
      if (routeData != null) {
        polylines = routeData.polylines;
        Uint8List bytes = await placeToMarker(origin, duration: null);
        final Marker originMarker = createMarker(
          id: 'origin',
          position: origin.position,
          bytes: bytes,
        );
        bytes = await placeToMarker(
          destination,
          duration: routeData.route.duration ~/ 60,
        );
        final Marker destinationMarker = createMarker(
          id: 'destination',
          position: destination.position,
          bytes: bytes,
        );
        markers[originMarker.markerId] = originMarker;
        markers[destinationMarker.markerId] = destinationMarker;
      }
    }

    yield this.state.copyWith(
          markers: markers,
          origin: origin,
          destination: destination,
          history: history,
          polylines: polylines,
        );

    if (cameraUpdate != null) {
      (await _mapController).animateCamera(cameraUpdate);
    }
  }

  Stream<HomeState> _mapOnMyLocationUpdate(OnMyLocationUpdate event) async* {
    if (this.state.myLocation == null) {
      Place origin = Place(
        id: 'origin',
        title: "Mi ubicación",
        position: event.location,
      );
      yield this.state.copyWith(
            loading: false,
            myLocation: event.location,
            origin: origin,
          );
    } else {
      yield this.state.copyWith(myLocation: event.location);
    }
  }
}
