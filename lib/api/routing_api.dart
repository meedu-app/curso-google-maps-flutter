import 'package:dio/dio.dart';
import 'package:google_maps/models/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutingAPI {
  RoutingAPI._internal();
  static RoutingAPI get instance => RoutingAPI._internal();

  final _dio = Dio();

  Future<List<Route>> calculate(LatLng origin, LatLng destination) async {
    try {
      final response = await this
          ._dio
          .get('https://router.hereapi.com/v8/routes', queryParameters: {
        "transportMode": "car",
        "origin": "${origin.latitude},${origin.longitude}",
        "destination": "${destination.latitude},${destination.longitude}",
        "return": "summary,polyline",
        "apiKey": "Gbc7sCYsHl8GPkkVoq4RsgSGURIkmBrTRqMDv8oIqm8",
        "routingMode": "fast",
        "alternatives": 1,
      });

      return (response.data['routes'] as List)
          .map((e) => Route.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }
}
