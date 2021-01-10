import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth.dart';
import 'facebook_auth.dart';

abstract class Authenticator {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> signInWithGoogle();
  Future<String> signInWithFacebook();
  Future<String> getUID();
  Future<void> signOut();
}

class Auth implements Authenticator {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signInWithEmailAndPassword(String email, String password) async {
    final UserCredential authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    final User user = authResult.user;
    return user?.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    final UserCredential authResult = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final User user = authResult.user;
    return user?.uid;
  }

  @override
  Future<String> signInWithGoogle() async {
    GoogleAuth userGoogleAccount = GoogleAuth();
    final UserCredential authResult = await _firebaseAuth.signInWithCredential(await userGoogleAccount.getGoogleCredential());
    final User user = authResult.user;
    return user?.uid;
  }

  @override
  Future<String> signInWithFacebook() async {
    FacebookAuth userFacebookAccount = FacebookAuth();
    final UserCredential authResult = await _firebaseAuth.signInWithCredential(await userFacebookAccount.getFacebookCredential());
    final User user = authResult.user;
    return user?.uid;
  }

  @override
  Future<String> getUID() async {
    final User user = _firebaseAuth.currentUser;
    return user?.uid; //if user != null, return uid, else return null
  }

  @override
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}