import 'package:flutter/material.dart';

import '../models/models.dart';

class AccidentReportsScreen extends StatelessWidget {
  final AppData appData;
  final Future<void> Function() onChanged;

  const AccidentReportsScreen({
    super.key,
    required this.appData,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Accident Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sequence format: ACC-1, ACC-2, ...', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_camera_rounded),
              label: const Text('Create Accident Report'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: appData.accidentReports.length,
                itemBuilder: (context, index) {
                  final accident = appData.accidentReports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text('${accident.reportNumber} • ${accident.vehiclePlate}'),
                      subtitle: Text('${accident.driverName} • ${accident.severity}'),
                      trailing: Chip(label: Text(accident.status.name)),
                      children: [
                        ListTile(title: Text(accident.description)),
                        ListTile(title: Text('Images attached: ${accident.imagePaths.length}')),
                        ListTile(title: Text('Status: ${accident.status.name}')),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('Add 4 Images'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.picture_as_pdf_rounded),
                              label: const Text('Export PDF'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
