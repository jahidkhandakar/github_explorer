class GithubUser {
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String name;
  final int publicRepos;

  GithubUser({
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.name,
    required this.publicRepos,
  });

  factory GithubUser.fromJson(Map<String, dynamic> j) => GithubUser(
    login: j['login'] ?? '',
    avatarUrl: j['avatar_url'] ?? '',
    htmlUrl: j['html_url'] ?? '',
    name: j['name'] ?? '',
    publicRepos: j['public_repos'] ?? 0,
  );
}