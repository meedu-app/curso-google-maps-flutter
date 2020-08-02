import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps/blocs/pages/home/home_bloc.dart';
import 'package:google_maps/blocs/pages/home/home_state.dart';

class CenteredMarked extends StatelessWidget {
  const CenteredMarked({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      if (state.mapPick == MapPick.none) return Container();

      return Transform.translate(
        offset: Offset(0, -22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40,
              constraints: BoxConstraints(maxWidth: 250),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (state.reverseGeocodeTask != null) ...[
                    if (state.reverseGeocodeTask.place != null)
                      AutoSizeText(
                        state.reverseGeocodeTask.place.title,
                        maxLines: 2,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10,
                      )
                    else
                      SizedBox(
                        width: 20,
                        child: SpinKitCircle(
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ] else
                    SizedBox(width: 10),
                ],
              ),
              decoration: BoxDecoration(
                color: Color(0xff102027),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  )
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  width: 2,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xff102027),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Color(0xff102027),
                    shape: BoxShape.circle,
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }
}
