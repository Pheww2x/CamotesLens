import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/variety_info.dart';
import '../utils/constants.dart';

class VarietiesScreen extends StatelessWidget {
  const VarietiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.varieties)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Text(
                'Reference information for the varieties supported by the CNN.'),
          ),
          ...supportedVarieties
              .map((variety) => _VarietyTile(variety: variety)),
        ],
      ),
    );
  }
}

class _VarietyTile extends StatelessWidget {
  const _VarietyTile({required this.variety});
  final VarietyInfo variety;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const CircleAvatar(
            backgroundColor: AppColors.emeraldLight,
            child: Icon(Icons.eco, color: AppColors.primary)),
        title: Text(variety.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(variety.leafCharacteristics),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _InfoLine(label: 'Common uses', value: variety.commonUses),
          _InfoLine(
              label: 'Growing information', value: variety.growingInformation),
          _InfoLine(
              label: 'Identifying characteristics',
              value: variety.identifyingCharacteristics),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RichText(
          text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
        TextSpan(
            text: '$label\n',
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.primary)),
        TextSpan(text: value)
      ])),
    );
  }
}
