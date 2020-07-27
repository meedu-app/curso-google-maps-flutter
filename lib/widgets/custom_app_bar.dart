import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Row(
                children: <Widget>[
                  Text(
                    "Search place ... ",
                    style: TextStyle(
                      color: Colors.black26,
                    ),
                  ),
                  Icon(Icons.search),
                ],
              ),
              onPressed: () {
                SearchPlacesDelegate delegate = SearchPlacesDelegate();
                showSearch(context: context, delegate: delegate);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 50);
}

class SearchPlacesDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {},
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("lalal");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text("🥶");
  }
}
