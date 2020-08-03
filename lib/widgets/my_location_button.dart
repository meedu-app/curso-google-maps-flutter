import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/blocs/pages/home/bloc.dart';
import '../blocs/pages/home/home_bloc.dart';

class MyLocationButton extends StatelessWidget {
  const MyLocationButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeBloc bloc = HomeBloc.of(context);
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      final bool hide = state.origin != null && state.destination != null;
      if (hide) return Container();

      return Positioned(
        bottom: 25,
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
    });
  }
}
