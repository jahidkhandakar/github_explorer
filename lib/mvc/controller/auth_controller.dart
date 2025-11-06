import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final user = Rxn<User>();
  final accessToken = RxnString(); // GitHub access token (if any)

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((u) => user.value = u);
  }

  Future<void> signInWithGithub() async {
    final provider = GithubAuthProvider();
    // provider.addScope('repo'); // uncomment if you need private repos later
    final cred = await _auth.signInWithProvider(provider);
    final oauth = cred.credential as OAuthCredential?;
    accessToken.value = oauth?.accessToken;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    accessToken.value = null;
  }

  String? currentToken() => accessToken.value;
}