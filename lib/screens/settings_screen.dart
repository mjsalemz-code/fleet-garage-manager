import 'package:flutter/material.dart';

import '../models/models.dart';

class AccidentReportsScreen extends StatefulWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;

  const AccidentReportsScreen({
    super.key,
    required this.appData,
    required this.onChanged,
  });

  @override
  State<AccidentReportsScreen> createState() => _AccidentReportsScreenState();
}

class _AccidentReportsScreenState extends State<AccidentReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AccidentStatus? _selectedStatus;

  List<AccidentReport> get filteredReports {
    final query = _searchController.text.trim().toLowerCase();
    return widget.appData.accidentReports.where((report) {
      final matchesQuery = query.isEmpty ||
          report.reportNumber.toLowerCase().contains(query) ||
          report.vehiclePlate.toLowerCase().contains(query) ||
          report.driverName.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == null || report.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _showAddReportDialog() {
    final formKey = GlobalKey<FormState>();
    final plateController = TextEditingController();
    final driverController = TextEditingController();
    final descriptionController = TextEditingController();
    final severityController = TextEditingController(text: 'Medium');

    AccidentStatus status = AccidentStatus.open;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Accident Report'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: plateController,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Vehicle Plate'),
                  ),
                  TextFormField(
                    controller: driverController,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Driver Name'),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: severityController,
                    decoration: const InputDecoration(labelText: 'Severity'),
                  ),
                  DropdownButtonFormField<AccidentStatus>(
                    value: status,
                    items: AccidentStatus.values
                        .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        status = value;
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final nextNumber = widget.appData.nextAccidentSequence();
                  final newReport = AccidentReport(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    reportNumber: 'ACC-$nextNumber',
                    vehiclePlate: plateController.text.trim(),
                    vehicleId: DateTime.now().millisecondsSinceEpoch.toString(),
                    driverName: driverController.text.trim(),
                    description: descriptionController.text.trim(),
                    severity: severityController.text.trim(),
                    status: status,
                    createdAt: DateTime.now(),
                    imagePaths: const [],
                  );

                  final updated = AppData(
                    vehicles: widget.appData.vehicles,
                    garageDepartments: widget.appData.garageDepartments,
                    companyDepartments: widget.appData.companyDepartments,
                    workOrders: widget.appData.workOrders,
                    accidentReports: [...widget.appData.accidentReports, newReport],
                  );

                  widget.onChanged(updated);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by plate or driver...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _showAddReportDialog,
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => setState(() => _selectedStatus = null),
                ),
                ...AccidentStatus.values.map(
                  (status) => ChoiceChip(
                    label: Text(status.name),
                    selected: _selectedStatus == status,
                    onSelected: (_) => setState(() {
                      _selectedStatus = _selectedStatus == status ? null : status;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredReports.isEmpty
                  ? const Center(child: Text('No accident reports found'))
                  : ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final accident = filteredReports[index];
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
