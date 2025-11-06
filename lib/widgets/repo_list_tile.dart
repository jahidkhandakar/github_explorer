import 'package:flutter/material.dart';
import '../mvc/model/github_repo.dart';
import 'package:intl/intl.dart';

class RepoListTile extends StatelessWidget {
  final GithubRepo repo;
  final VoidCallback onTap;
  const RepoListTile({super.key, required this.repo, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd();
    return ListTile(
      title: Text(repo.name),
      subtitle: Text(repo.description.isEmpty ? 'No description' : repo.description,
          maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('⭐ ${repo.stargazersCount}'),
          Text('Updated: ${df.format(repo.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      onTap: onTap,
    );
  }
}