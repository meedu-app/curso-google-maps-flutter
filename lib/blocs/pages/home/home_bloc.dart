import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/blocs/pages/home/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/utils/extras.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'home_events.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvents, HomeState> {
  Geolocator _geolocator = Geolocator();
  final LocationPermissions _locationPermissions = LocationPermissions();
  Completer<GoogleMapController> _completer = Completer();

  final Completer<Marker> _myPositionMarker = Completer();
  final LocationOptions _locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

  StreamSubscription<Position> _subscription;
  StreamSubscription<ServiceStatus> _subscriptionGpsStatus;

  Polyline myRoute = Polyline(
    polylineId: PolylineId('my_route'),
    width: 5,
    color: Colors.redAccent,
  );

  Polygon myTaps = Polygon(
      polygonId: PolygonId('my_taps_polygon'),
      fillColor: Colors.redAccent,
      strokeWidth: 3,
      strokeColor: Colors.white);

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

  _init() async {
    this._loadCarPin();

    _subscription = _geolocator.getPositionStream(_locationOptions).listen(
      (Position position) async {
        if (position != null) {
          final newPosition = LatLng(position.latitude, position.longitude);
          add(
            OnMyLocationUpdate(
              newPosition,
            ),
          );

          // final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(newPosition);
          // await (await _mapController).animateCamera(cameraUpdate);
        }
      },
    );

    if (Platform.isAndroid) {
      //final bool enabled = await _geolocator.isLocationServiceEnabled();

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
      await (await _mapController).animateCamera(cameraUpdate);
    }
  }

  _loadCarPin() async {
    final Uint8List bytes = await loadAsset('assets/car-pin.png', width: 40);
    final marker = Marker(
      markerId: MarkerId('my_position_marker'),
      icon: BitmapDescriptor.fromBytes(bytes),
      anchor: Offset(0.5, 0.5),
    );
    this._myPositionMarker.complete(marker);
  }

  void setMapController(GoogleMapController controller) {
    print("🎃");
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
    } else if (event is OnMapTap) {
      yield* this._mapOnMapTap(event);
    }
  }

  Stream<HomeState> _mapOnMyLocationUpdate(OnMyLocationUpdate event) async* {
    //  this.myRoute.points.add(event.location);
    List<LatLng> points = List<LatLng>.from(this.myRoute.points);
    points.add(event.location);

    this.myRoute = this.myRoute.copyWith(pointsParam: points);
    print("points ${this.myRoute.points.length}");

    Map<PolylineId, Polyline> polylines =
        Map<PolylineId, Polyline>.from(this.state.polylines);

    polylines[this.myRoute.polylineId] = this.myRoute;

    final markers = Map<MarkerId, Marker>.from(this.state.markers);

    double rotation = 0;
    LatLng lastPosition = this.state.myLocation;
    if (lastPosition != null) {
      rotation = getCoordsRotation(event.location, lastPosition);
    }

    final Marker myPositionMarker =
        (await this._myPositionMarker.future).copyWith(
      positionParam: event.location,
      rotationParam: rotation,
    );

    markers[myPositionMarker.markerId] = myPositionMarker;

    yield this.state.copyWith(
        loading: false,
        myLocation: event.location,
        polylines: polylines,
        markers: markers);
  }

  Stream<HomeState> _mapOnMapTap(OnMapTap event) async* {
    final markerId = MarkerId(this.state.markers.length.toString());
    final info = InfoWindow(
      title: "HEllO ${markerId.value}",
      snippet: "la direcccion etc etc",
    );

    // final Uint8List bytes =
    //     await loadAsset('assets/car-pin.png', width: 50, height: 90);

    final Uint8List bytes = await loadImageFromNetwork(
      'https://cdn.domestika.org/c_fill,dpr_auto,h_256,t_base_params.format_jpg,w_256/v1506185040/avatars/000/150/905/150905-original.jpg?1506185040',
      width: 100,
      height: 100,
    );

    final customIcon = BitmapDescriptor.fromBytes(bytes);
    final marker = Marker(
      markerId: markerId,
      position: event.location,
      icon: customIcon,
      anchor: Offset(0.5, 0.5),
      onTap: () {
        print("😀 😀 ${markerId.value}");
      },
      draggable: true,
      onDragEnd: (newPosition) {
        print("😀 😀 ${markerId.value} new position $newPosition");
      },
      infoWindow: info,
    );

    final markers = Map<MarkerId, Marker>.from(this.state.markers);
    markers[markerId] = marker;

    List<LatLng> points = List<LatLng>.from(this.myTaps.points);
    points.add(event.location);
    this.myTaps = this.myTaps.copyWith(pointsParam: points);
    Map<PolygonId, Polygon> polygons =
        Map<PolygonId, Polygon>.from(this.state.polygons);
    polygons[this.myTaps.polygonId] = this.myTaps;

    yield this.state.copyWith(markers: markers, polygons: polygons);
  }
}
