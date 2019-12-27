import 'package:google_sign_in/google_sign_in.dart';

class AuthManager {

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/drive.file'
    ],
  );

  GoogleSignInAccount _acc;

  Future<GoogleSignInAccount> getAccount({bool silently = false}) async {
    if (_acc == null) {
      _acc = await _signInSilently();
      if (_acc == null && !silently) {
        _acc = await _signIn();
      }
    }
    return _acc;
  }

  Future<GoogleSignInAccount> _signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<GoogleSignInAccount> _signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      _acc = null;
      _googleSignIn.signOut();
      _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
  }
}
