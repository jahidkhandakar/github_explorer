import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final user = Rxn<User>();
  final accessToken = RxnString();

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((u) => user.value = u);
  }

  Future<void> signInWithGithub() async {
    final provider = GithubAuthProvider();
    // If you ever want private repos later:
    // provider.addScope('repo');

    final cred = await _auth.signInWithProvider(provider);

    final authCred = cred.credential;
    if (authCred is OAuthCredential) {
      // only read token if it's really an OAuth credential
      accessToken.value = authCred.accessToken;
    } else {
      // fallback: no token, app will use PAT/public GitHub
      accessToken.value = null;
    }

    // user.value will be updated automatically by authStateChanges listener
  }

  Future<void> signOut() async {
    await _auth.signOut();
    accessToken.value = null;
  }

  String? currentToken() => accessToken.value;
}
