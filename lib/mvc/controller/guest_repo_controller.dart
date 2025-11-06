import 'package:get/get.dart';
import '../model/github_repo.dart';
import '../model/github_user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/api_client.dart';

enum RepoSort { name, stars, created, updated }
enum ViewMode { list, grid }

class GuestRepoController extends GetxController {
  final _dio = ApiClient.dio;

  final loading = false.obs;
  final error = ''.obs;

  final user = Rxn<GithubUser>();
  final repos = <GithubRepo>[].obs;

  final queryUser = ''.obs; // input username
  final search = ''.obs;    // repo search
  final sort = RepoSort.updated.obs;
  final ascending = false.obs;
  final viewMode = ViewMode.list.obs;

  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  bool _loadingMore = false;

  List<GithubRepo> _all = [];

  Future<void> loadFirst(String username) async {
    if (username.trim().isEmpty) return;
    loading.value = true;
    error.value = '';
    repos.clear();
    try {
      final u = await _dio.get('/users/$username');
      user.value = GithubUser.fromJson(u.data);

      _page = 1;
      final list = await _fetchPage(username, page: _page);
      repos.assignAll(list);
      _all = List.from(repos);
      apply();
    } catch (e) {
      error.value = friendlyError(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    final username = user.value?.login ?? '';
    if (username.isEmpty || !_hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      _page += 1;
      final next = await _fetchPage(username, page: _page);
      repos.addAll(next);
      _all = List.from(repos);
      apply();
    } finally {
      _loadingMore = false;
    }
  }

  Future<List<GithubRepo>> _fetchPage(String username, {required int page}) async {
    final res = await _dio.get('/users/$username/repos', queryParameters: {
      'page': page,
      'per_page': _perPage,
      'sort': _sortKeyForApi(sort.value),
      'direction': ascending.value ? 'asc' : 'desc',
    });
    final list = (res.data as List).cast<Map<String, dynamic>>();
    final repos = list.map(GithubRepo.fromJson).toList();
    _hasMore = repos.length == _perPage;
    return repos;
  }

  void apply() {
    var out = List<GithubRepo>.from(repos);
    final q = search.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((r) =>
        r.name.toLowerCase().contains(q) ||
        (r.description.toLowerCase()).contains(q)
      ).toList();
    }
    out.sort((a, b) {
      int c;
      switch (sort.value) {
        case RepoSort.name:    c = a.name.toLowerCase().compareTo(b.name.toLowerCase()); break;
        case RepoSort.stars:   c = a.stargazersCount.compareTo(b.stargazersCount); break;
        case RepoSort.created: c = a.createdAt.compareTo(b.createdAt); break;
        case RepoSort.updated: c = a.updatedAt.compareTo(b.updatedAt); break;
      }
      return ascending.value ? c : -c;
    });
    repos.assignAll(out);
  }

  void setSort(RepoSort s) { sort.value = s; if (user.value != null) loadFirst(user.value!.login); }
  void toggleAsc() { ascending.value = !ascending.value; if (user.value != null) loadFirst(user.value!.login); }
  void setSearch(String q) { search.value = q; apply(); }
  void toggleView() { viewMode.value = viewMode.value == ViewMode.list ? ViewMode.grid : ViewMode.list; }

  String _sortKeyForApi(RepoSort s) {
    switch (s) {
      case RepoSort.created: return 'created';
      case RepoSort.updated: return 'updated';
      case RepoSort.name:    return 'full_name';
      case RepoSort.stars:   return 'updated';
    }
  }
}