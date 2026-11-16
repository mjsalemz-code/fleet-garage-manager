import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/pdf_export_service.dart';

class AccidentReportsScreen extends StatefulWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;
  const AccidentReportsScreen({super.key, required this.appData, required this.onChanged});
  @override
  State<AccidentReportsScreen> createState() => _AccidentReportsScreenState();
}

class _AccidentReportsScreenState extends State<AccidentReportsScreen> {
  final _search = TextEditingController();
  final _picker = ImagePicker();
  AccidentStatus? _status;

  List<AccidentReport> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return widget.appData.accidentReports.where((r) => (_status == null || r.status == _status) &&
      (q.isEmpty || r.reportNumber.toLowerCase().contains(q) || r.vehiclePlate.toLowerCase().contains(q) || r.driverName.toLowerCase().contains(q) || r.description.toLowerCase().contains(q))).toList();
  }

  Future<void> _create() async {
    final form = GlobalKey<FormState>();
    final plate = TextEditingController();
    final driver = TextEditingController();
    final description = TextEditingController();
    final severity = TextEditingController(text: 'Medium');
    AccidentStatus status = AccidentStatus.open;
    final report = await showDialog<AccidentReport>(context: context, builder: (context) => StatefulBuilder(builder: (context, refresh) => AlertDialog(
      title: const Text('New accident report'), content: Form(key: form, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: plate, decoration: const InputDecoration(labelText: 'Vehicle plate'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: driver, decoration: const InputDecoration(labelText: 'Driver'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: description, decoration: const InputDecoration(labelText: 'Accident details'), maxLines: 4, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: severity, decoration: const InputDecoration(labelText: 'Severity')),
        DropdownButtonFormField<AccidentStatus>(value: status, decoration: const InputDecoration(labelText: 'Status'), items: AccidentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(), onChanged: (v) { if (v != null) refresh(() => status = v); }),
      ]))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (!form.currentState!.validate()) return;
          final vehicle = widget.appData.vehicles.where((v) => v.plateNumber.toLowerCase() == plate.text.trim().toLowerCase()).firstOrNull;
          Navigator.pop(context, AccidentReport(id: DateTime.now().microsecondsSinceEpoch.toString(), reportNumber: 'ACC-${widget.appData.nextAccidentSequence()}',
            vehiclePlate: plate.text.trim(), vehicleId: vehicle?.id ?? '', driverName: driver.text.trim(), description: description.text.trim(), severity: severity.text.trim(), status: status, createdAt: DateTime.now()));
        }, child: const Text('Create')],
    )));
    if (report == null) return;
    widget.onChanged(AppData(vehicles: widget.appData.vehicles, garageDepartments: widget.appData.garageDepartments,
      companyDepartments: widget.appData.companyDepartments, workOrders: widget.appData.workOrders,
      accidentReports: [...widget.appData.accidentReports, report], inventoryParts: widget.appData.inventoryParts));
  }

  Future<void> _addImages(AccidentReport report, ImageSource source) async {
    try {
      final remaining = 4 - report.imagePaths.length;
      if (remaining <= 0) return;
      final selected = source == ImageSource.gallery
          ? await _picker.pickMultiImage(imageQuality: 80, limit: remaining)
          : [if (await _picker.pickImage(source: source, imageQuality: 80) case final image?) image];
      final paths = selected.map((e) => e.path).take(remaining).toList();
      if (paths.isEmpty) return;
      final updatedReport = AccidentReport(id: report.id, reportNumber: report.reportNumber, vehiclePlate: report.vehiclePlate,
        vehicleId: report.vehicleId, driverName: report.driverName, description: report.description, severity: report.severity,
        status: report.status, createdAt: report.createdAt, imagePaths: [...report.imagePaths, ...paths]);
      final reports = widget.appData.accidentReports.map((e) => e.id == report.id ? updatedReport : e).toList();
      widget.onChanged(AppData(vehicles: widget.appData.vehicles, garageDepartments: widget.appData.garageDepartments,
        companyDepartments: widget.appData.companyDepartments, workOrders: widget.appData.workOrders,
        accidentReports: reports, inventoryParts: widget.appData.inventoryParts));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add images: $error')));
    }
  }

  Future<void> _chooseImageSource(AccidentReport report) async {
    final source = await showModalBottomSheet<ImageSource>(context: context, builder: (context) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take photo'), onTap: () => Navigator.pop(context, ImageSource.camera)),
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
    ])));
    if (source != null) await _addImages(report, source);
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Accident Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const Text('Sequential references: ACC-1, ACC-2, ...', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 14),
    Row(children: [Expanded(child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search plate, driver or report')),
      const SizedBox(width: 8), FilledButton.icon(onPressed: _create, icon: const Icon(Icons.add), label: const Text('New'))]),
    Wrap(spacing: 6, children: [ChoiceChip(label: const Text('All'), selected: _status == null, onSelected: (_) => setState(() => _status = null)),
      ...AccidentStatus.values.map((s) => ChoiceChip(label: Text(s.name), selected: _status == s, onSelected: (_) => setState(() => _status = s)))]),
    Expanded(child: _filtered.isEmpty ? const Center(child: Text('No accident reports found')) : ListView.builder(itemCount: _filtered.length, itemBuilder: (context, index) {
      final report = _filtered[index];
      return Card(child: ExpansionTile(title: Text('${report.reportNumber} • ${report.vehiclePlate}'), subtitle: Text('${report.driverName} • ${report.severity}'), trailing: Chip(label: Text(report.status.name)), children: [
        ListTile(title: Text(report.description)), ListTile(title: Text('${report.imagePaths.length} / 4 images attached')),
        if (report.imagePaths.isNotEmpty) SizedBox(height: 90, child: ListView(scrollDirection: Axis.horizontal, children: report.imagePaths.map((path) => Padding(padding: const EdgeInsets.all(4), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(path, width: 90, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 90, color: Colors.white10, child: const Icon(Icons.image)))))).toList())),
        Wrap(alignment: WrapAlignment.end, children: [TextButton.icon(onPressed: report.imagePaths.length >= 4 ? null : () => _chooseImageSource(report), icon: const Icon(Icons.add_a_photo), label: const Text('Add images')),
          TextButton.icon(onPressed: () => PdfExportService.accident(report), icon: const Icon(Icons.picture_as_pdf), label: const Text('Print / Export PDF'))]),
      ]));
    })),
  ])));
}
