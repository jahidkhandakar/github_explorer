import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/guest_repo_controller.dart';
import '../controller/theme_controller.dart';
import '../../widgets/repo_list_tile.dart';
import '../../widgets/repo_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../utils/routes.dart';

class GuestHomeView extends StatefulWidget {
  const GuestHomeView({super.key});
  @override
  State<GuestHomeView> createState() => _GuestHomeViewState();
}

class _GuestHomeViewState extends State<GuestHomeView> {
  late final GuestRepoController ctrl;
  final _scroll = ScrollController();
  final _usernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(GuestRepoController());
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
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final u = ctrl.user.value?.login ?? '';
          return Text(u.isEmpty ? 'Guest Mode' : '$u\'s Repos');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeCtrl.toggle,
          ),
        ],
      ),

      // bottom nav like auth mode
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    tooltip: 'Back to Welcome',
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Get.offAllNamed(Routes.welcome);
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
        final username = ctrl.user.value?.login ?? '';

        return RefreshIndicator(
          onRefresh: () async {
            if (username.isNotEmpty) {
              await ctrl.loadFirst(username);
            }
          },
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              // 🔝 Row 1: username search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Enter GitHub username (e.g., flutter)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (v) => ctrl.loadFirst(v.trim()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            ctrl.loadFirst(_usernameCtrl.text.trim()),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔝 Row 2: repo filter + view toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText:
                                'Filter repos by name / description...',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: ctrl.setSearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (ctrl.loading.value && ctrl.repos.isEmpty)
                const SliverFillRemaining(child: LoadingView())
              else if (ctrl.error.isNotEmpty && ctrl.repos.isEmpty)
                SliverFillRemaining(
                  child: ErrorView(
                    message: ctrl.error.value,
                    onRetry: () =>
                        ctrl.loadFirst(_usernameCtrl.text.trim()),
                  ),
                )
              else
                _buildRepoSliver(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRepoSliver() {
    final ctrl = Get.find<GuestRepoController>();

    if (ctrl.repos.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No repositories loaded yet')),
      );
    }

    if (ctrl.viewMode.value == ViewMode.list) {
      return SliverList.separated(
        itemCount: ctrl.repos.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          if (i == ctrl.repos.length) {
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
    } else {
      return SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverGrid.builder(
          itemCount: ctrl.repos.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, i) {
            if (i == ctrl.repos.length) {
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
  }

  void _showSortSheet(GuestRepoController c) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
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

  Widget _sortTile(GuestRepoController c, RepoSort value, String label) {
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
