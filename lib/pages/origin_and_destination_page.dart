import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/api/search_api.dart';
import 'package:google_maps/models/place.dart';
import 'package:google_maps/utils/debounce.dart';

class OriginAndDestinationPage extends StatefulWidget {
  final Place origin;

  const OriginAndDestinationPage({Key key, @required this.origin})
      : super(key: key);

  @override
  _OriginAndDestinationPageState createState() =>
      _OriginAndDestinationPageState();
}

class _OriginAndDestinationPageState extends State<OriginAndDestinationPage> {
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();

  bool _originHasFocus = true;
  SearchAPI _searchAPI = SearchAPI.instance;
  Debounce _debounce = Debounce(Duration(milliseconds: 300));
  StreamSubscription _subscription;
  TextEditingController _originController, _destinationController;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController(text: widget.origin.title);
    _destinationController = TextEditingController();
    _originFocus.addListener(() {
      setState(() {
        _originHasFocus = true;
      });
    });

    _destinationFocus.addListener(() {
      setState(() {
        _originHasFocus = false;
      });
    });
  }

  @override
  void dispose() {
    _originController?.dispose();
    _destinationController?.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    _searchAPI.cancel();
    _debounce.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  _onInputChanged(String query) {
    if (_subscription != null) {
      _subscription.cancel();
    }
    if (query.trim().length >= 3) {
      _searchAPI.cancel();
      _debounce.create(() => this._search(query));
    } else {
      _debounce.cancel();
      _searchAPI.cancel();
    }
  }

  _search(String query) {
    _subscription = _searchAPI
        .search(
          query,
          widget.origin.position,
        )
        .asStream()
        .listen((List<Place> results) {
      if (results != null) {
        print("llego ${results.length}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "A donde vas?",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    _Input(
                      onChanged: this._onInputChanged,
                      hasFocus: this._originHasFocus,
                      focusNode: _originFocus,
                      controller: _originController,
                      iconData: Icons.gps_fixed,
                      placeholder: "Tu punto de salida",
                    ),
                    SizedBox(height: 10),
                    _Input(
                      onChanged: this._onInputChanged,
                      hasFocus: !this._originHasFocus,
                      focusNode: _destinationFocus,
                      controller: _destinationController,
                      iconData: Icons.pin_drop,
                      placeholder: "Dinos a donde vas?",
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final IconData iconData;
  final String placeholder;
  final FocusNode focusNode;
  final bool hasFocus;
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _Input(
      {Key key,
      @required this.iconData,
      this.placeholder = '',
      @required this.focusNode,
      this.hasFocus = false,
      this.controller,
      @required this.onChanged})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      focusNode: this.focusNode,
      controller: this.controller,
      onChanged: this.onChanged,
      prefix: Padding(
        padding: EdgeInsets.all(5.0),
        child: Icon(this.iconData),
      ),
      placeholder: this.placeholder,
      decoration: BoxDecoration(
        color: Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: 2,
          color: this.hasFocus ? Colors.blue : Colors.white,
        ),
      ),
    );
  }
}
