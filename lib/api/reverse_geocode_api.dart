import 'package:dio/dio.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/latlng_extension.dart';

class ReverseGeocodeAPI {
  ReverseGeocodeAPI._internal();
  static ReverseGeocodeAPI get instance => ReverseGeocodeAPI._internal();

  final _dio = Dio();

  Future<Place> reverse(LatLng at) async {
    try {
      final Response response = await this._dio.get(
        'https://revgeocode.search.hereapi.com/v1/revgeocode',
        queryParameters: {
          "apiKey": "Gbc7sCYsHl8GPkkVoq4RsgSGURIkmBrTRqMDv8oIqm8",
          "lang": "es-ES",
          "limit": 1,
          "at": at.format()
        },
      );

      final list = response.data['items'] as List;
      if (list.length > 0) {
        final place = Place(
          id: list[0]['id'],
          title: list[0]['title'],
          position: at,
        );
        return place;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
