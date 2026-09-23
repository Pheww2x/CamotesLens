import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/classification_history.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _historyService = HistoryService();
  late Future<List<ClassificationHistory>> _history;

  @override
  void initState() {
    super.initState();
    _history = _historyService.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: FutureBuilder<List<ClassificationHistory>>(
        future: _history,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <ClassificationHistory>[];
          final average = items.isEmpty
              ? 0.0
              : items.map((item) => item.confidence).reduce((a, b) => a + b) /
                  items.length;
          final counts = <String, int>{};
          for (final item in items) {
            counts[item.predictedClass] =
                (counts[item.predictedClass] ?? 0) + 1;
          }
          final mostDetected = counts.isEmpty
              ? 'No data yet'
              : counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
          final pending = items.where((item) => !item.isSynced).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.emeraldLight,
                      child: Icon(Icons.person,
                          color: AppColors.primary, size: 30)),
                  title: const Text('Leaf Researcher',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${items.length} saved classifications'),
                ),
              ),
              const SizedBox(height: 14),
              Text('Classification statistics',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _StatCard(
                        label: 'Classifications', value: '${items.length}')),
                Expanded(
                    child: _StatCard(
                        label: 'Average confidence',
                        value: '${(average * 100).toStringAsFixed(1)}%')),
                Expanded(
                    child:
                        _StatCard(label: 'Most detected', value: mostDetected))
              ]),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(
                      pending == 0
                          ? Icons.cloud_done
                          : Icons.cloud_upload_outlined,
                      color: AppColors.primary),
                  title: const Text('History sync',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(pending == 0
                      ? 'All records are marked as synced.'
                      : '$pending record(s) waiting for connection.'),
                  trailing: pending == 0
                      ? null
                      : TextButton(
                          onPressed: () async {
                            await _historyService.markPendingAsSynced();
                            setState(() => _history = _historyService.load());
                          },
                          child: const Text('Sync')),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                  child: ListTile(
                      leading:
                          Icon(Icons.offline_bolt, color: AppColors.primary),
                      title: Text('Offline-ready records'),
                      subtitle: Text(
                          'Classification history and favorites remain available without an internet connection.'))),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 6),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 11), maxLines: 2)
          ])),
    );
  }
}
