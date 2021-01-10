import 'package:flutter/material.dart';
import 'login_page.dart';
import '../utils.dart';
import '../authentication/authprovider.dart';
import '../authentication/authenticator.dart';

const Test_Page = "/";

enum AuthStatus {
  notDetermined,
  notSignedIn,
  SignedIn,
}

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage>{
  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Authenticator auth = AuthProvider.of(context).auth;
    auth.getUID().then((String userID) {
      setState(() {
        authStatus = userID == null ? AuthStatus.notSignedIn : AuthStatus.SignedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.SignedIn;
    });
  }
  void _signedOut() {
    final Authenticator auth = AuthProvider.of(context).auth;
    auth.getUID().then((String userID) {
      if(userID != null){
        auth.signOut();
      }
      setState(() {
        authStatus = AuthStatus.notSignedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return WaitingScreen(_signedOut);
        break;
      case AuthStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
        );
        break;
      case AuthStatus.SignedIn:
        return Navigator(
          onGenerateRoute: _HomeRoutes(),
        );
        break;
      default:
        return ErrorScreen(_signedOut);
    }
  }

  RouteFactory _HomeRoutes() {
    return (settings) {
      final Map<String, dynamic> arguments = settings.arguments;
      Widget screen;
      switch(settings.name){
        case Test_Page:
          screen = TestPage(onSignedOut: _signedOut);break;
        default:
          screen = LoginPage(onSignedIn: _signedIn);
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}