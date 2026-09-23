import 'dart:io';

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/classification_history.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = HistoryService();
  late Future<List<ClassificationHistory>> _items;

  @override
  void initState() {
    super.initState();
    _items = _service.load();
  }

  void _reload() => setState(() => _items = _service.load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.history)),
      body: FutureBuilder<List<ClassificationHistory>>(
        future: _items,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
                child: Text('Your classifications will appear here.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: _HistoryThumbnail(path: item.imagePath),
                  title: Text(item.predictedClass,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${item.createdAt.toLocal().toString().split('.').first}\nConfidence ${(item.confidence * 100).toStringAsFixed(1)}%'),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip:
                        item.isFavorite ? 'Remove favorite' : 'Save favorite',
                    icon: Icon(item.isFavorite ? Icons.star : Icons.star_border,
                        color: AppColors.amberAccent),
                    onPressed: () async {
                      await _service.toggleFavorite(item.id);
                      _reload();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryThumbnail extends StatelessWidget {
  const _HistoryThumbnail({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: File(path).existsSync()
          ? Image.file(File(path), width: 58, height: 58, fit: BoxFit.cover)
          : Container(
              width: 58,
              height: 58,
              color: AppColors.emeraldSubtle,
              child: const Icon(Icons.eco)),
    );
  }
}
