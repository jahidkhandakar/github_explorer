import 'package:get/get.dart';
import '../model/github_repo.dart';
import '../model/github_user.dart';
import '../../utils/exceptions.dart';
import '../../utils/api_client.dart';

enum RepoSort { name, stars, created, updated }
enum ViewMode { list, grid }

class UserRepoController extends GetxController {
  final _dio = ApiClient.dio;

  final loading = false.obs;
  final error = ''.obs;

  final me = Rxn<GithubUser>();
  final currentListOwner = ''.obs; // whose repos are currently shown
  final repos = <GithubRepo>[].obs;

  final search = ''.obs; // repo search local
  final sort = RepoSort.updated.obs;
  final ascending = false.obs;
  final viewMode = ViewMode.list.obs;

  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  final loadingMore = false.obs;

  List<GithubRepo> _all = [];

  @override
  void onInit() {
    super.onInit();
    _loadSelf();
  }

  Future<void> _loadSelf() async {
    loading.value = true;
    error.value = '';
    repos.clear();
    _all = [];
    _page = 1;
    _hasMore = true;
    loadingMore.value = false;

    try {
      final u = await _dio.get('/user'); // token required
      me.value = GithubUser.fromJson(u.data);
      currentListOwner.value = me.value!.login;

      final first = await _fetchUserRepos(page: _page);
      _all = List.from(first);
      repos.assignAll(first);
      apply();
    } catch (e) {
      error.value = friendlyError(e);
    } finally {
      loading.value = false;
    }
  }

  Future<List<GithubRepo>> _fetchUserRepos({required int page}) async {
    final res = await _dio.get(
      '/user/repos',
      queryParameters: {
        'page': page,
        'per_page': _perPage,
        'sort': _sortKeyForApi(sort.value),
        'direction': ascending.value ? 'asc' : 'desc',
      },
    );
    final list = (res.data as List).cast<Map<String, dynamic>>();
    final result = list.map(GithubRepo.fromJson).toList();
    _hasMore = result.length == _perPage;
    return result;
  }

  Future<List<GithubRepo>> _fetchReposOf(
    String username, {
    required int page,
  }) async {
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
    final result = list.map(GithubRepo.fromJson).toList();
    _hasMore = result.length == _perPage;
    return result;
  }

  Future<void> showUser(String username) async {
    if (username.isEmpty) return;
    loading.value = true;
    error.value = '';
    repos.clear();
    _all = [];
    _page = 1;
    _hasMore = true;
    loadingMore.value = false;

    try {
      final u = await _dio.get('/users/$username');
      currentListOwner.value = GithubUser.fromJson(u.data).login;

      final first =
          await _fetchReposOf(currentListOwner.value, page: _page);
      _all = List.from(first);
      repos.assignAll(first);
      apply();
    } catch (e) {
      error.value = friendlyError(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || loadingMore.value) return;

    loadingMore.value = true;
    try {
      _page += 1;
      final showingSelf = currentListOwner.value == (me.value?.login ?? '');
      final nextFuture = showingSelf
          ? _fetchUserRepos(page: _page)
          : _fetchReposOf(currentListOwner.value, page: _page);
      final next = await nextFuture;
      _all.addAll(next);
      apply();
    } finally {
      loadingMore.value = false;
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
    final owner = currentListOwner.value;
    if (owner.isEmpty) return;

    if (owner == (me.value?.login ?? '')) {
      _loadSelf();
    } else {
      showUser(owner);
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
        // GitHub API doesn't sort directly by stars here, we sort locally.
        return 'updated';
    }
  }
}
