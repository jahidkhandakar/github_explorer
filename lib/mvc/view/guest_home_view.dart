import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/guest_repo_controller.dart';
import '../controller/theme_controller.dart';
import '../../utils/routes.dart';
import '../../widgets/repo_list_tile.dart';
import '../../widgets/repo_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';

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
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
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
        title: const Text('Guest Mode'),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: themeCtrl.toggle),
        ],
      ),
      body: Obx(() {
        final u = ctrl.user.value?.login ?? '';
        return RefreshIndicator(
          onRefresh: () async {
            if (u.isNotEmpty) await ctrl.loadFirst(u);
          },
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
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
                      onPressed: () => ctrl.loadFirst(_usernameCtrl.text.trim()),
                      child: const Text('Search'),
                    ),
                  ]),
                ),
              ),
              if (ctrl.loading.value && ctrl.repos.isEmpty)
                const SliverFillRemaining(child: LoadingView())
              else if (ctrl.error.isNotEmpty && ctrl.repos.isEmpty)
                SliverFillRemaining(child:
                  ErrorView(message: ctrl.error.value, onRetry: () => ctrl.loadFirst(_usernameCtrl.text.trim())))
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
    if (ctrl.viewMode.value == ViewMode.list) {
      return SliverList.separated(
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
      );
    } else {
      return SliverPadding(
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
    }
  }
}