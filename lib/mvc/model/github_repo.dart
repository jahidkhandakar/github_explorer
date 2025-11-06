class GithubRepo {
  final String name;
  final String fullName;
  final String htmlUrl;
  final String description;
  final int stargazersCount;
  final int forksCount;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  GithubRepo({
    required this.name,
    required this.fullName,
    required this.htmlUrl,
    required this.description,
    required this.stargazersCount,
    required this.forksCount,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> j) => GithubRepo(
    name: j['name'] ?? '',
    fullName: j['full_name'] ?? '',
    htmlUrl: j['html_url'] ?? '',
    description: j['description'] ?? '',
    stargazersCount: j['stargazers_count'] ?? 0,
    forksCount: j['forks_count'] ?? 0,
    language: j['language'] ?? '',
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime(1970),
    updatedAt: DateTime.tryParse(j['updated_at'] ?? '') ?? DateTime(1970),
  );
}