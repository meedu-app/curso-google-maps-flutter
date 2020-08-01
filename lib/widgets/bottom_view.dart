import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/blocs/pages/home/home_bloc.dart';
import 'package:google_maps/blocs/pages/home/home_state.dart';

class BottomView extends StatelessWidget {
  const BottomView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = HomeBloc.of(context);

    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      final bool confirm = state.origin != null && state.destination != null;

      return Container(
        padding: EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: confirm ? Color(0xff102027) : Color(0xffd2d2d2),
            child: Text(
              confirm ? "Solicitar conductor" : "A donde vas?",
              style: TextStyle(
                color: confirm ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              if (confirm) {
              } else {
                bloc.whereYouGo(context);
              }
            },
          ),
        ),
      );
    });
  }
}
