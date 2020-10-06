import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:google_maps/api/reverse_geocode_api.dart';
import 'package:google_maps/blocs/pages/home/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/models/reverse_geocode_task.dart';
import 'package:google_maps/native/background_location.dart';
import 'package:google_maps/pages/origin_and_destination_page.dart';
import 'package:google_maps/utils/extras.dart';
import 'package:google_maps/utils/map_style.dart';
import 'package:google_maps/utils/socket_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'bloc.dart';
import 'home_events.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvents, HomeState> {
  final LocationPermissions _locationPermissions = LocationPermissions();
  Completer<GoogleMapController> _completer = Completer();

  ReverseGeocodeAPI _reverseGeocodeAPI = ReverseGeocodeAPI.instance;

  StreamSubscription _subscription;
  StreamSubscription<ServiceStatus> _subscriptionGpsStatus;

  Future<GoogleMapController> get _mapController async {
    return await _completer.future;
  }

  HomeBloc() : super(HomeState.initialState) {
    this._init();
  }

  @override
  Future<void> close() async {
    await BackgroundLocation.instance.stop();
    _subscription?.cancel();
    _subscriptionGpsStatus?.cancel();
    SocketClient.instance.disconnect();
    super.close();
  }

  static HomeBloc of(BuildContext context) =>
      BlocProvider.of<HomeBloc>(context);

  _init() async {
    SocketClient.instance.connect();
    BackgroundLocation.instance.start();

    _subscription = BackgroundLocation.instance.stream.listen(
      (LatLng position) {
        SocketClient.instance.sendLocation(position);
        add(OnMyLocationUpdate(position));
      },
    );

    if (Platform.isAndroid) {
      _subscriptionGpsStatus = _locationPermissions.serviceStatus.listen(
        (status) {
          add(
            OnGpsEnabled(status == ServiceStatus.enabled),
          );
        },
      );
    }
  }

  goToMyPosition() async {
    if (this.state.myLocation != null) {
      this._goTo(this.state.myLocation);
    }
  }

  _goTo(LatLng position) async {
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(position);
    await (await _mapController).moveCamera(cameraUpdate);
  }

  whereYouGo({bool hasOriginFocus = false}) async {
    final List<Place> history = this.state.history.values.toList();

    final Place itemSelected = await Get.to(
        OriginAndDestinationPage(
          origin: this.state.origin,
          destination: this.state.destination,
          hasOriginFocus: hasOriginFocus,
          history: history,
          onOriginChanged: (Place origin) {
            add(
              ConfirmPoint(origin, true),
            );
          },
          onMapPick: (bool isOrigin) {
            add(
              OnMapPick(isOrigin ? MapPick.origin : MapPick.destination),
            );
          },
        ),
        fullscreenDialog: true);

    if (itemSelected != null) {
      add(ConfirmPoint(itemSelected, false));
    }
  }

  void onCameraMoveStarted() {
    ReverseGeocodeTask task = ReverseGeocodeTask(
      isOrigin: this.state.mapPick == MapPick.origin,
    );
    add(AddReverseGeocodeTask(task));
  }

  Future<void> reverseGeocode(LatLng at) async {
    final place = await _reverseGeocodeAPI.reverse(at);
    add(FinishReverseGeocodeTask(place));
  }

  void setMapController(GoogleMapController controller) {
    if (_completer.isCompleted) {
      _completer = Completer();
    }
    controller.setMapStyle(jsonEncode(mapStyle));
    _completer.complete(controller);
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvents event) async* {
    if (event is OnMyLocationUpdate) {
      yield* this._mapOnMyLocationUpdate(event);
    } else if (event is OnGpsEnabled) {
      yield this.state.copyWith(gpsEnabled: event.enabled);
    } else if (event is ConfirmPoint) {
      yield* this._mapConfirmPoint(event);
    } else if (event is OnMapPick) {
      yield this.state.copyWith(mapPick: event.pick);
    } else if (event is AddReverseGeocodeTask) {
      yield this.state.copyWith(reverseGeocodeTask: event.task);
    } else if (event is FinishReverseGeocodeTask) {
      final task = this.state.reverseGeocodeTask.copyWith(place: event.place);
      yield this.state.copyWith(reverseGeocodeTask: task);
    } else if (event is Reset) {
      yield this.state.reset();
    }
  }

  void _onOriginTap() {
    this.whereYouGo(hasOriginFocus: true);
  }

  void _onDestinationTap() {
    this.whereYouGo();
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

    Uint8List bytes = await placeToMarker(origin, duration: null);
    final Marker originMarker = createMarker(
      id: 'origin',
      position: origin.position,
      bytes: bytes,
      onTap: this._onOriginTap,
    );

    markers[originMarker.markerId] = originMarker;

    MapPick mapPick;

    if (origin != null && destination != null) {
      mapPick = MapPick.none;
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

        bytes = await placeToMarker(
          destination,
          duration: routeData.route.duration ~/ 60,
        );
        final Marker destinationMarker = createMarker(
          id: 'destination',
          position: destination.position,
          bytes: bytes,
          onTap: this._onDestinationTap,
        );

        markers[destinationMarker.markerId] = destinationMarker;
      }
    }

    yield this.state.copyWith(
          markers: markers,
          origin: origin,
          destination: destination,
          history: history,
          polylines: polylines,
          mapPick: mapPick,
        );

    if (cameraUpdate != null) {
      (await _mapController).animateCamera(cameraUpdate);
    }

    if (origin != null && destination == null) {
      this.whereYouGo();
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
