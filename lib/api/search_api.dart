import 'package:dio/dio.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchAPI {
  SearchAPI._internal();
  static SearchAPI get instance => SearchAPI._internal();

  final Dio _dio = Dio();
  CancelToken _cancelToken;

  Future<List<Place>> search(String query, LatLng at) async {
    try {
      _cancelToken = CancelToken();
      final response = await this
          ._dio
          .get('https://places.ls.hereapi.com/places/v1/autosuggest',
              queryParameters: {
                "q": query,
                "apiKey": "Gbc7sCYsHl8GPkkVoq4RsgSGURIkmBrTRqMDv8oIqm8",
                "at": "${at.latitude},${at.longitude}",
              },
              cancelToken: _cancelToken);
      final List<Place> places = (response.data['results'] as List)
          .where((element) => element['position'] != null)
          .map((item) => Place.fromJson(item))
          .toList();
      _cancelToken = null;
      return places;
    } catch (e) {
      print(e);
      return null;
    }
  }

  cancel() {
    if (_cancelToken != null && !_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
  }
}
