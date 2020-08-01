import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flexible_polyline/flexible_polyline.dart';
import 'package:flexible_polyline/latlngz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps/api/routing_api.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/models/route.dart' as heremaps;
import 'package:google_maps/widgets/my_custom_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> loadAsset(
  String path, {
  int width = 50,
}) async {
  ByteData data = await rootBundle.load(path);
  final Uint8List bytes = data.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: width,
  );

  final ui.FrameInfo frame = await codec.getNextFrame();
  data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}

Future<Uint8List> loadImageFromNetwork(
  String url, {
  int width = 50,
  int height = 50,
}) async {
  final http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    final Uint8List bytes = response.bodyBytes;
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
      targetHeight: height,
    );

    final ui.FrameInfo frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }
  throw new Exception("download failed");
}

double getCoordsRotation(LatLng currentPosition, LatLng lastPosition) {
  final dx = math.cos(math.pi / 180 * lastPosition.latitude) *
      (currentPosition.longitude - lastPosition.longitude);
  final dy = currentPosition.latitude - lastPosition.latitude;
  final angle = math.atan2(dy, dx);

  return 90 - angle * 180 / math.pi;
}

Future<Uint8List> placeToMarker(Place place, Color color) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  ui.Canvas canvas = ui.Canvas(recorder);
  final ui.Size size = ui.Size(300, 90);
  MyCustomMarker customMarker = MyCustomMarker(place, color);
  customMarker.paint(canvas, size);
  ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(
    size.width.toInt(),
    size.height.toInt(),
  );

  final ByteData byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return byteData.buffer.asUint8List();
}

CameraUpdate centerMap(LatLng origin, LatLng destination,
    {double padding = 30}) {
  final double left = math.min(origin.latitude, destination.latitude);
  final double right = math.max(origin.latitude, destination.latitude);
  final double top = math.min(origin.longitude, destination.longitude);
  final double bottom = math.max(origin.longitude, destination.longitude);

  final LatLng southwest = LatLng(left, bottom);
  final LatLng northeast = LatLng(right, top);
  final LatLngBounds bounds = LatLngBounds(
    southwest: southwest,
    northeast: northeast,
  );

  final CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
    bounds,
    padding,
  );
  return cameraUpdate;
}

List<LatLng> decodeEncodedPolyline(String encoded) {
  List<LatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    final coord = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    poly.add(coord);
  }
  return poly;
}

Marker createMarker({
  @required String id,
  @required LatLng position,
  @required Uint8List bytes,
}) {
  final markerId = MarkerId(id);
  final marker = Marker(
    markerId: markerId,
    position: position,
    icon: BitmapDescriptor.fromBytes(bytes),
  );
  return marker;
}

Future<Map<PolylineId, Polyline>> createRoute({
  @required Map<PolylineId, Polyline> polylines,
  @required LatLng origin,
  @required LatLng destination,
}) async {
  final newPolylines = Map<PolylineId, Polyline>.from(polylines);
  final routes = await RoutingAPI.instance.calculate(origin, destination);

  if (routes != null && routes.length > 0) {
    final PolylineId polylineId = PolylineId('route');
    final heremaps.Route route = routes[0];

    final List<LatLngZ> tmp = FlexiblePolyline.decode(route.polyline);
    final List<LatLng> points = tmp.map((e) => LatLng(e.lat, e.lng)).toList();

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      width: 4,
      color: Colors.blue,
      points: points,
    );
    newPolylines[polylineId] = polyline;

    return newPolylines;
  }
  return null;
}
