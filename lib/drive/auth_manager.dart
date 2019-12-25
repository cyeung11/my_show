import 'package:google_sign_in/google_sign_in.dart';



class AuthManager {

//  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/drive.file'
    ],
  );

  Future<GoogleSignInAccount> getAccount() async {
    var account = await _signInSilently();
    if (account == null) {
      account = await _signIn();
    }
    return account;
//    if (account != null) {
//      final GoogleSignInAuthentication authentication = await account.authentication;

//      final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: authentication.accessToken,
//        idToken: authentication.idToken,
//      );

//      final AuthResult authResult = await _auth.signInWithCredential(credential);
//      final FirebaseUser user = authResult.user;

//      return await account.authHeaders;
//    } else {
//      return null;
//    }
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
      _googleSignIn.signOut();
      _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
  }
}
