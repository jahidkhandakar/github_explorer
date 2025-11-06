import 'package:get/get.dart';
import '../mvc/view/welcome_view.dart';
import '../mvc/view/guest_home_view.dart';
import '../mvc/view/auth_home_view.dart';
import '../mvc/view/repo_details_view.dart';
import '../mvc/model/github_repo.dart';

class Routes {
  static const welcome = '/';
  static const guestHome = '/guest';
  static const authHome = '/auth';
  static const details = '/details';

  static final pages = <GetPage>[
    GetPage(name: welcome, page: () => const WelcomeView()),
    GetPage(name: guestHome, page: () => const GuestHomeView()),
    GetPage(name: authHome, page: () => const AuthHomeView()),
    GetPage(name: details, page: () => const RepoDetailsView()),
  ];
}

class RepoDetailsArgs {
  final GithubRepo repo;
  const RepoDetailsArgs(this.repo);
}

class AppNav {
  static void toGuestHome() => Get.toNamed(Routes.guestHome);
  static void toAuthHome() => Get.toNamed(Routes.authHome);
  static void toRepoDetails(GithubRepo repo) =>
      Get.toNamed(Routes.details, arguments: RepoDetailsArgs(repo));
  static void back<T>([T? result]) => Get.back(result: result);
}