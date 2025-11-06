import 'package:flutter/material.dart';
import '../mvc/model/github_repo.dart';

class RepoCard extends StatelessWidget {
  final GithubRepo repo;
  final VoidCallback onTap;
  const RepoCard({super.key, required this.repo, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(repo.name, style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Expanded(child: Text(
                repo.description.isEmpty ? 'No description' : repo.description,
                maxLines: 3, overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 4),
                Text('${repo.stargazersCount}'),
                const Spacer(),
                Text(repo.language.isEmpty ? '—' : repo.language),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}