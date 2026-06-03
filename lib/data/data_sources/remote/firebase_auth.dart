import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get user => _firebaseAuth.currentUser;

  static Future<User> signUp(
      {required String email, required String password}) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = result.user!;
    return user;
  }

  static Future<User> logIn(
      {required String email, required String password}) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = result.user!;
    return user;
  }

  static Future<bool> isThisEmailToken({required String email}) async {
    try {
      ///TODO: handle this with other way
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: "dummy_password",
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false; // email not registered
      }
    }
    return true;
  }

  static Future<UserCredential> signInWithGoogle() async {
    try {
      // Check if running on web
      if (kIsWeb) {
        // Web: use signInWithPopup directly — no google_sign_in needed
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile: use google_sign_in package
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) throw Exception('Sign in cancelled');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _firebaseAuth.signInWithCredential(credential);
      }
    } catch (e) {
      throw Exception("Google Sign-In Failed: ${e.toString()}");
    }
  }

  static Future signOut() async => await _firebaseAuth.signOut();
}