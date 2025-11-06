import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/routes.dart';
import '../controller/theme_controller.dart';

class RepoDetailsView extends StatelessWidget {
  const RepoDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as RepoDetailsArgs;
    final repo = args.repo; // GithubRepo from model
    final themeCtrl = Get.find<ThemeController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(repo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeCtrl.toggle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title + name
          Row(
            children: [
              Icon(Icons.book_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  repo.fullName.isNotEmpty ? repo.fullName : repo.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          if (repo.description.isNotEmpty)
            Text(
              repo.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

          const SizedBox(height: 16),

          // Chips: stars, forks, language
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _ChipIcon(
                icon: Icons.star_border_rounded,
                label: '${repo.stargazersCount} stars',
              ),
              _ChipIcon(
                icon: Icons.call_split,
                label: '${repo.forksCount} forks',
              ),
              if (repo.language.isNotEmpty)
                _ChipIcon(icon: Icons.code, label: repo.language),
            ],
          ),

          const SizedBox(height: 20),

          // Info rows: created / updated dates
          _InfoRow(label: 'Created at', value: _fmtDate(repo.createdAt)),
          _InfoRow(label: 'Last updated', value: _fmtDate(repo.updatedAt)),

          const SizedBox(height: 24),

          // Open on GitHub button
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open on GitHub'),
            onPressed: () async {
              if (repo.htmlUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Missing GitHub URL')),
                );
                return;
              }

              final url = Uri.parse(repo.htmlUrl);

              final ok = await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );

              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open GitHub URL')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final styleLabel = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
    );
    final styleValue = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value, style: styleValue)),
        ],
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChipIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
      backgroundColor: scheme.surfaceVariant.withOpacity(0.7),
    );
  }
}
