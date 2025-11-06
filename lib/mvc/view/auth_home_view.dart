import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_repo_controller.dart';
import '../controller/theme_controller.dart';
import '../controller/auth_controller.dart';
import '../../utils/routes.dart';
import '../../widgets/repo_list_tile.dart';
import '../../widgets/repo_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';

class AuthHomeView extends StatefulWidget {
  const AuthHomeView({super.key});
  @override
  State<AuthHomeView> createState() => _AuthHomeViewState();
}

class _AuthHomeViewState extends State<AuthHomeView> {
  late final UserRepoController ctrl;
  final _scroll = ScrollController();
  final _otherUserCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(UserRepoController());
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _otherUserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final me = ctrl.me.value?.login ?? '';
          final owner = ctrl.currentListOwner.value;
          return Text(owner.isEmpty ? 'Loading...' : '$owner\'s Repos');
        }),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: themeCtrl.toggle),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              AppNav.back();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.loading.value && ctrl.repos.isEmpty) return const LoadingView();
        if (ctrl.error.isNotEmpty && ctrl.repos.isEmpty) {
          return ErrorView(message: ctrl.error.value, onRetry: () => ctrl.setSort(ctrl.sort.value));
        }

        final sliverBody = ctrl.viewMode.value == ViewMode.list
            ? SliverList.separated(
                itemCount: ctrl.repos.length + 1,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  if (i == ctrl.repos.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator())),
                    );
                  }
                  final r = ctrl.repos[i];
                  return RepoListTile(repo: r, onTap: () => AppNav.toRepoDetails(r));
                },
              )
            : SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid.builder(
                  itemCount: ctrl.repos.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1.25, mainAxisSpacing: 8, crossAxisSpacing: 8),
                  itemBuilder: (context, i) {
                    if (i == ctrl.repos.length) {
                      return const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }
                    final r = ctrl.repos[i];
                    return RepoCard(repo: r, onTap: () => AppNav.toRepoDetails(r));
                  },
                ),
              );

        return RefreshIndicator(
          onRefresh: () async => ctrl.setSort(ctrl.sort.value),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _otherUserCtrl,
                        decoration: const InputDecoration(
                          hintText: "Search other's username...",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (v) => ctrl.showUser(v.trim()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => ctrl.showUser(_otherUserCtrl.text.trim()),
                      child: const Text('Go'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'My repos',
                      icon: const Icon(Icons.home),
                      onPressed: () => ctrl.setSort(ctrl.sort.value),
                    )
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Filter repos...',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: ctrl.setSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Toggle view',
                      icon: Obx(() => Icon(
                        ctrl.viewMode.value == ViewMode.list ? Icons.grid_view : Icons.view_list)),
                      onPressed: ctrl.toggleView,
                    ),
                  ]),
                ),
              ),
              sliverBody,
            ],
          ),
        );
      }),
    );
  }
}