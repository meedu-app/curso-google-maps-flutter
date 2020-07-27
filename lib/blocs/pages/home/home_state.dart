import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;

class HomeState extends Equatable {
  final LatLng myLocation;
  final bool loading, gpsEnabled;
  final Map<MarkerId, Marker> markers;
  final Map<PolylineId, Polyline> polylines;
  final Map<PolygonId, Polygon> polygons;

  HomeState(
      {this.myLocation,
      this.loading,
      this.markers,
      this.gpsEnabled,
      this.polylines,
      this.polygons});

  static HomeState get initialState => new HomeState(
        myLocation: null,
        loading: true,
        markers: Map(),
        polylines: Map(),
        polygons: Map(),
        gpsEnabled: Platform.isIOS,
      );

  HomeState copyWith(
      {LatLng myLocation,
      bool loading,
      bool gpsEnabled,
      Map<MarkerId, Marker> markers,
      Map<PolylineId, Polyline> polylines,
      Map<PolygonId, Polygon> polygons}) {
    return HomeState(
      myLocation: myLocation ?? this.myLocation,
      loading: loading ?? this.loading,
      markers: markers ?? this.markers,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      polylines: polylines ?? this.polylines,
      polygons: polygons ?? this.polygons,
    );
  }

  @override
  List<Object> get props =>
      [myLocation, loading, markers, gpsEnabled, polylines];
}
