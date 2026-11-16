import 'package:flutter/material.dart';

import '../models/models.dart';

class SettingsScreen extends StatelessWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;

  const SettingsScreen({
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
            const Text('System Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            _SettingsTile(title: 'Garage Departments', subtitle: '${appData.garageDepartments.length} configured'),
            _SettingsTile(title: 'Company Departments', subtitle: '${appData.companyDepartments.length} configured'),
            _SettingsTile(title: 'Vehicle Statuses', subtitle: 'Available, Garage, Spare, Inspection'),
            _SettingsTile(title: 'Offline Backup', subtitle: 'JSON backup system ready for device-to-device transfer'),
            _SettingsTile(title: 'Camera/Scanner', subtitle: 'Plate recognition and accident image import ready'),
            _SettingsTile(title: 'Full Screen', subtitle: 'Immersive mode enabled for app launch'),
            _SettingsTile(title: 'Export', subtitle: 'PDF report export for work orders and accident files'),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.settings_applications_rounded),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
