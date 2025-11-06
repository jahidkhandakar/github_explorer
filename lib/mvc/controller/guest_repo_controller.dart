import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../model/github_repo.dart';
import '../model/github_user.dart';
import '../../utils/api_client.dart';
import '../../utils/exceptions.dart';

enum RepoSort { name, stars, created, updated }
enum ViewMode { list, grid }

class GuestRepoController extends GetxController {
  final _dio = ApiClient.dio;

  final loading = false.obs;
  final error = ''.obs;

  final user = Rxn<GithubUser>(); // whose repos we're viewing
  final repos = <GithubRepo>[].obs;

  final search = ''.obs;          // local filter
  final sort = RepoSort.updated.obs;
  final ascending = false.obs;
  final viewMode = ViewMode.list.obs;

  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  bool _loadingMore = false;

  List<GithubRepo> _all = [];

  Future<void> loadFirst(String username) async {
    if (username.isEmpty) return;
    loading.value = true;
    error.value = '';
    repos.clear();
    _all = [];
    _page = 1;
    _hasMore = true;

    try {
      // load user info
      final uRes = await _dio.get('/users/$username');
      user.value = GithubUser.fromJson(uRes.data);

      // load first page of repos
      final first = await _fetchReposOf(username, page: _page);
      _all = List.from(first);
      repos.assignAll(first);
      apply();
    } catch (e) {
      error.value = friendlyError(e);
    } finally {
      loading.value = false;
    }
  }

  Future<List<GithubRepo>> _fetchReposOf(String username,
      {required int page}) async {
    final res = await _dio.get(
      '/users/$username/repos',
      queryParameters: {
        'page': page,
        'per_page': _perPage,
        'sort': _sortKeyForApi(sort.value),
        'direction': ascending.value ? 'asc' : 'desc',
      },
    );
    final list = (res.data as List).cast<Map<String, dynamic>>();
    final repos = list.map(GithubRepo.fromJson).toList();
    _hasMore = repos.length == _perPage;
    return repos;
  }

  Future<void> loadMore() async {
    final username = user.value?.login ?? '';
    if (username.isEmpty) return;
    if (!_hasMore || _loadingMore) return;

    _loadingMore = true;
    try {
      _page += 1;
      final next = await _fetchReposOf(username, page: _page);
      _all.addAll(next);
      apply();
    } finally {
      _loadingMore = false;
    }
  }

  void apply() {
    var out = List<GithubRepo>.from(_all);

    final q = search.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((r) {
        final desc = r.description.toLowerCase();
        return r.name.toLowerCase().contains(q) || desc.contains(q);
      }).toList();
    }

    out.sort((a, b) {
      int c;
      switch (sort.value) {
        case RepoSort.name:
          c = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case RepoSort.stars:
          c = a.stargazersCount.compareTo(b.stargazersCount);
          break;
        case RepoSort.created:
          c = a.createdAt.compareTo(b.createdAt);
          break;
        case RepoSort.updated:
          c = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return ascending.value ? c : -c;
    });

    repos.assignAll(out);
  }

  void setSearch(String q) {
    search.value = q;
    apply();
  }

  void setSort(RepoSort s) {
    sort.value = s;
    // re-fetch from GitHub to respect API sorting as well
    final username = user.value?.login ?? '';
    if (username.isEmpty) return;
    _page = 1;
    _hasMore = true;
    _reload(username);
  }

  Future<void> _reload(String username) async {
    loading.value = true;
    error.value = '';
    repos.clear();
    _all = [];
    try {
      final first = await _fetchReposOf(username, page: _page);
      _all = List.from(first);
      repos.assignAll(first);
      apply();
    } catch (e) {
      error.value = friendlyError(e);
    } finally {
      loading.value = false;
    }
  }

  void toggleAsc() {
    ascending.value = !ascending.value;
    apply();
  }

  void toggleView() {
    viewMode.value =
        viewMode.value == ViewMode.list ? ViewMode.grid : ViewMode.list;
  }

  String _sortKeyForApi(RepoSort s) {
    switch (s) {
      case RepoSort.created:
        return 'created';
      case RepoSort.updated:
        return 'updated';
      case RepoSort.name:
        return 'full_name';
      case RepoSort.stars:
        // GitHub API doesn't offer `stars` sort here directly for /users/:user/repos,
        // but we still sort locally by stars in apply().
        return 'updated';
    }
  }
}
