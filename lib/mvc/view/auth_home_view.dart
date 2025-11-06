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
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
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
          final owner = ctrl.currentListOwner.value;
          return Text(
            owner.isEmpty ? 'Loading...' : "$owner's Repos",
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle theme',
            onPressed: themeCtrl.toggle,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Get.offAllNamed(Routes.welcome);
            },
          ),
        ],
      ),

      // bottom nav bar: Home, Sort, Asc/Desc, Grid/List
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    tooltip: 'My repos',
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      final meLogin = ctrl.me.value?.login ?? '';
                      if (meLogin.isNotEmpty) {
                        ctrl.showUser(meLogin);
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'Sort / Filter',
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showSortSheet(ctrl),
                  ),
                  IconButton(
                    tooltip: 'Ascending / Descending',
                    icon: Icon(
                      ctrl.ascending.value
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    onPressed: ctrl.toggleAsc,
                  ),
                  IconButton(
                    tooltip: 'Toggle view',
                    icon: Icon(
                      ctrl.viewMode.value == ViewMode.list
                          ? Icons.grid_view
                          : Icons.view_list,
                    ),
                    onPressed: ctrl.toggleView,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Obx(() {
        if (ctrl.loading.value && ctrl.repos.isEmpty) {
          return const LoadingView();
        }

        if (ctrl.error.isNotEmpty && ctrl.repos.isEmpty) {
          return ErrorView(
            message: ctrl.error.value,
            onRetry: () => ctrl.setSort(ctrl.sort.value),
          );
        }

        final sliverBody =
            ctrl.viewMode.value == ViewMode.list ? _buildList() : _buildGrid();

        return RefreshIndicator(
          onRefresh: () async => ctrl.setSort(ctrl.sort.value),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              // Row 1: other user search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
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
                        onPressed: () =>
                            ctrl.showUser(_otherUserCtrl.text.trim()),
                        child: const Text('Go'),
                      ),
                    ],
                  ),
                ),
              ),

              // Row 2: repo filter
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Filter repos by name / description...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: ctrl.setSearch,
                  ),
                ),
              ),

              sliverBody,
            ],
          ),
        );
      }),
    );
  }

  SliverList _buildList() {
    final showLoader = ctrl.loadingMore.value;
    return SliverList.separated(
      itemCount: ctrl.repos.length + (showLoader ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, i) {
        if (showLoader && i == ctrl.repos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        final r = ctrl.repos[i];
        return RepoListTile(
          repo: r,
          onTap: () => AppNav.toRepoDetails(r),
        );
      },
    );
  }

  SliverPadding _buildGrid() {
    final showLoader = ctrl.loadingMore.value;
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid.builder(
        itemCount: ctrl.repos.length + (showLoader ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.25,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, i) {
          if (showLoader && i == ctrl.repos.length) {
            return const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            );
          }
          final r = ctrl.repos[i];
          return RepoCard(
            repo: r,
            onTap: () => AppNav.toRepoDetails(r),
          );
        },
      ),
    );
  }

  void _showSortSheet(UserRepoController c) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort repositories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _sortTile(c, RepoSort.name, 'Name (A → Z / Z → A)'),
            _sortTile(c, RepoSort.stars, 'Stars (High ↔ Low)'),
            _sortTile(
              c,
              RepoSort.created,
              'Created date (Newest ↔ Oldest)',
            ),
            _sortTile(
              c,
              RepoSort.updated,
              'Updated date (Newest ↔ Oldest)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(UserRepoController c, RepoSort value, String label) {
    return Obx(
      () => RadioListTile<RepoSort>(
        value: value,
        groupValue: c.sort.value,
        onChanged: (v) {
          if (v != null) {
            c.sort.value = v;
            c.setSort(v);
            Get.back();
          }
        },
        title: Text(label),
      ),
    );
  }
}
