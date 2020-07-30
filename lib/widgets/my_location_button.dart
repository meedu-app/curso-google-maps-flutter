import 'package:flutter/material.dart';

import '../blocs/pages/home/home_bloc.dart';
import '../blocs/pages/home/home_bloc.dart';

class MyLocationButton extends StatelessWidget {
  const MyLocationButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeBloc bloc = HomeBloc.of(context);
    return Positioned(
      bottom: 15,
      right: 15,
      child: FloatingActionButton(
        onPressed: () => bloc.goToMyPosition(),
        child: Icon(
          Icons.gps_fixed,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
