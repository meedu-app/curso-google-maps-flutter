import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class BackgroundLocation {
  BackgroundLocation._init();
  final Geolocator _geolocator = Geolocator();
  static BackgroundLocation _instance = BackgroundLocation._init();
  static BackgroundLocation get instance => _instance;

  final LocationOptions _locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  final _channel = MethodChannel('app.meedu/geolocation');
  final _eventChannel = EventChannel("app.meedu/geolocation-listener");

  StreamController<LatLng> _streamController = StreamController.broadcast();
  Stream<LatLng> get stream => _streamController.stream;

  StreamSubscription _androidSubs, _iosSubs;
  bool _listenning = false;

  Future<void> start() async {
    if (_listenning) {
      throw new Exception("gelocation already listenning");
    }
    if (Platform.isIOS) {
      _iosSubs = _eventChannel.receiveBroadcastStream().listen((event) {
        final data = Map<String, dynamic>.from(event);
        _streamController.sink.add(LatLng(data['lat'], data['lng']));
      });
    } else {
      _androidSubs = _geolocator.getPositionStream(_locationOptions).listen(
        (Position position) async {
          if (position != null) {
            _streamController.sink.add(
              LatLng(position.latitude, position.longitude),
            );
          }
        },
      );
    }
    await _channel.invokeMethod('start');
    _listenning = true;
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
    _streamController.close();
    if (Platform.isIOS) {
      await _iosSubs?.cancel();
    } else {
      await _androidSubs?.cancel();
    }
    _listenning = false;
  }
}
