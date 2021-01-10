import 'package:flutter/material.dart';

Widget paddedText(String text, {double fontsize = 24.0}) {
  return Container(
    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    alignment: Alignment.center,
    child: Text(
      text,
      style: TextStyle(fontSize: fontsize),
      textAlign: TextAlign.center,
    ),
  );
}

Widget WaitingScreen(Function cancelAction,
    {Widget waitingWidget = const CircularProgressIndicator(),
      String showText = ""}) {
  return Scaffold(
      body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              waitingWidget,
              showText != ""
                  ? paddedText(showText, fontsize: 24.0)
                  : SizedBox(
                  height: 10), //if no text provided, return empty view
              Container(
                child: RaisedButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: cancelAction,
                ),
              )
            ],
          )));
}

Widget ErrorScreen(Function backAction, {String errorText = ""}) {
  return Scaffold(
      body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              errorText != ""
                  ? paddedText(errorText, fontsize: 24.0)
                  : paddedText("Application Error...", fontsize: 24.0),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 5, 20),
                child: RaisedButton(
                  child: Text(
                    'Back',
                    style: TextStyle(fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: backAction,
                ),
              )
            ],
          )
      )
  );
}

class TestPage extends StatefulWidget {
  final VoidCallback onSignedOut;
  const TestPage({this.onSignedOut});
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: widget.onSignedOut,
              child: Text("Log out"),
            )
          ],
        ),
      ),
    );
  }
}