import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/blocs/pages/home/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/utils/extras.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'bloc.dart';
import 'bloc.dart';
import 'home_events.dart';
import 'home_state.dart';
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

  goToPlace(Place place) async {
    await Future.delayed(Duration(milliseconds: 300));
    add(GoToPlace(place));
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(place.position);
    await (await _mapController).animateCamera(cameraUpdate);
  }

  void setMapController(GoogleMapController controller) {
    if (_completer.isCompleted) {
      _completer = Completer();
    }
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
    } else if (event is GoToPlace) {
      yield* this._mapGoToPlace(event);
    } else if (event is ConfirmPoint) {
      yield* this._mapConfirmPoint(event);
    }
  }

  Stream<HomeState> _mapConfirmPoint(ConfirmPoint event) async* {
    final MarkerId markerId = MarkerId('arrival');
    final Uint8List bytes = await placeToMarker(event.place);
    final Marker marker = Marker(
      markerId: markerId,
      position: event.place.position,
      icon: BitmapDescriptor.fromBytes(bytes),
    );
    final markers = Map<MarkerId, Marker>.from(this.state.markers);
    markers[markerId] = marker;
    yield this.state.copyWith(markers: markers);
  }

  Stream<HomeState> _mapOnMyLocationUpdate(OnMyLocationUpdate event) async* {
    yield this.state.copyWith(loading: false, myLocation: event.location);
  }

  Stream<HomeState> _mapGoToPlace(GoToPlace event) async* {
    final history = Map<String, Place>.from(this.state.history);
    // final MarkerId markerId = MarkerId('place');

    // final Uint8List bytes = await placeToMarker(event.place);

    // final Marker marker = Marker(
    //   markerId: markerId,
    //   position: event.place.position,
    //   icon: BitmapDescriptor.fromBytes(bytes),
    // );

    // final markers = Map<MarkerId, Marker>.from(this.state.markers);
    // markers[markerId] = marker;

    if (history[event.place.id] == null) {
      history[event.place.id] = event.place;
      yield this.state.copyWith(
            history: history,
            arrival: event.place,
            // markers: markers,
          );
    } else {
      //yield this.state.copyWith(markers: markers);
      yield this.state.copyWith(arrival: event.place);
    }
  }
}
