import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/blocs/pages/home/bloc.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = HomeBloc.of(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state.mapPick == MapPick.none && state.destination == null) {
          return Container();
        }

        return Positioned(
          left: 10,
          top: 10,
          child: SafeArea(
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                bloc.add(Reset());
              },
              heroTag: 'reset',
            ),
          ),
        );
      },
    );
  }
}
