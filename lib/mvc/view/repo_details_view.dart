import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/routes.dart';

class RepoDetailsView extends StatelessWidget {
  const RepoDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as RepoDetailsArgs;
    final repo = args.repo;
    final df = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: Text(repo.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(repo.fullName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(repo.description.isEmpty ? 'No description' : repo.description),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 8, children: [
            Chip(label: Text('⭐ ${repo.stargazersCount}')),
            Chip(label: Text('🍴 ${repo.forksCount}')),
            Chip(label: Text(repo.language.isEmpty ? '—' : repo.language)),
          ]),
          const SizedBox(height: 12),
          Text('Created: ${df.format(repo.createdAt)}'),
          Text('Updated: ${df.format(repo.updatedAt)}'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final uri = Uri.parse(repo.htmlUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.link),
            label: const Text('Open on GitHub'),
          ),
        ],
      ),
    );
  }
}