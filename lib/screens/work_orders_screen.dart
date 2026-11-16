import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pdf_export_service.dart';

class WorkOrdersScreen extends StatefulWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;
  const WorkOrdersScreen({super.key, required this.appData, required this.onChanged});
  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  final _search = TextEditingController();
  WorkOrderStatus? _status;

  List<WorkOrder> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return widget.appData.workOrders.where((o) => (_status == null || o.status == _status) &&
      (query.isEmpty || o.workOrderNumber.toLowerCase().contains(query) || o.vehiclePlate.toLowerCase().contains(query) ||
        o.technician.toLowerCase().contains(query) || o.department.toLowerCase().contains(query))).toList();
  }

  Future<void> _create() async {
    final form = GlobalKey<FormState>();
    final plate = TextEditingController();
    final issue = TextEditingController();
    final requested = TextEditingController();
    final technician = TextEditingController();
    final partRows = <({TextEditingController name, TextEditingController serial, TextEditingController qty})>[];
    void addPart() => partRows.add((name: TextEditingController(), serial: TextEditingController(), qty: TextEditingController(text: '1')));
    addPart();
    String department = widget.appData.garageDepartments.where((e) => e.isActive).firstOrNull?.name ?? 'Mechanical';
    WorkOrderStatus status = WorkOrderStatus.pending;
    final result = await showDialog<WorkOrder>(context: context, builder: (context) => StatefulBuilder(builder: (context, refresh) => AlertDialog(
      title: const Text('Create work order'),
      content: SizedBox(width: 500, child: Form(key: form, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: plate, decoration: const InputDecoration(labelText: 'Vehicle plate'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: issue, decoration: const InputDecoration(labelText: 'Issue / requested work'), maxLines: 3, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: requested, decoration: const InputDecoration(labelText: 'Requested by')),
        TextFormField(controller: technician, decoration: const InputDecoration(labelText: 'Technician')),
        DropdownButtonFormField<String>(value: department, decoration: const InputDecoration(labelText: 'Garage department'),
          items: widget.appData.garageDepartments.where((e) => e.isActive).map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(), onChanged: (v) { if (v != null) department = v; }),
        DropdownButtonFormField<WorkOrderStatus>(value: status, decoration: const InputDecoration(labelText: 'Status'),
          items: WorkOrderStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(), onChanged: (v) { if (v != null) status = v; }),
        const SizedBox(height: 12),
        Row(children: [const Expanded(child: Text('Parts used', style: TextStyle(fontWeight: FontWeight.bold))), IconButton(onPressed: () { refresh(() => addPart()); }, icon: const Icon(Icons.add_circle_outline), tooltip: 'Add part row')]),
        ...partRows.map((row) => Column(children: [
          TextFormField(controller: row.name, decoration: const InputDecoration(labelText: 'Part name')),
          Row(children: [Expanded(child: TextFormField(controller: row.serial, decoration: const InputDecoration(labelText: 'Serial number'))), const SizedBox(width: 8), SizedBox(width: 90, child: TextFormField(controller: row.qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty'))),
            IconButton(onPressed: partRows.length == 1 ? null : () => refresh(() => partRows.remove(row)), icon: const Icon(Icons.remove_circle_outline))]),
        ])),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (!form.currentState!.validate()) return;
          final vehicle = widget.appData.vehicles.where((v) => v.plateNumber.toLowerCase() == plate.text.trim().toLowerCase()).firstOrNull;
          final items = partRows.where((r) => r.name.text.trim().isNotEmpty).map((r) => PartUsage(partName: r.name.text.trim(), serialNumber: r.serial.text.trim(), quantity: int.tryParse(r.qty.text) ?? 1)).toList();
          Navigator.pop(context, WorkOrder(id: DateTime.now().microsecondsSinceEpoch.toString(), workOrderNumber: 'GRG-${widget.appData.nextWorkOrderSequence()}',
            vehiclePlate: plate.text.trim(), vehicleId: vehicle?.id ?? '', vehicleMake: vehicle?.make ?? '', vehicleModel: vehicle?.model ?? '',
            issueSummary: issue.text.trim(), requestedBy: requested.text.trim(), department: department, technician: technician.text.trim(), status: status, createdAt: DateTime.now(), items: items));
        }, child: const Text('Create'))],
    )));
    if (result == null) return;
    widget.onChanged(AppData(vehicles: widget.appData.vehicles, garageDepartments: widget.appData.garageDepartments,
      companyDepartments: widget.appData.companyDepartments, workOrders: [...widget.appData.workOrders, result],
      accidentReports: widget.appData.accidentReports, inventoryParts: widget.appData.inventoryParts));
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Work Orders', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const Text('Sequential references: GRG-1, GRG-2, ...', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 14),
    Row(children: [Expanded(child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search order, vehicle, technician'))),
      const SizedBox(width: 8), FilledButton.icon(onPressed: _create, icon: const Icon(Icons.add), label: const Text('New'))]),
    Wrap(spacing: 6, children: [ChoiceChip(label: const Text('All'), selected: _status == null, onSelected: (_) => setState(() => _status = null)),
      ...WorkOrderStatus.values.map((s) => ChoiceChip(label: Text(s.name), selected: _status == s, onSelected: (_) => setState(() => _status = s)))]),
    const SizedBox(height: 8),
    Expanded(child: _filtered.isEmpty ? const Center(child: Text('No work orders found')) : ListView.builder(itemCount: _filtered.length, itemBuilder: (context, index) {
      final order = _filtered[index];
      return Card(child: ExpansionTile(title: Text('${order.workOrderNumber} • ${order.vehiclePlate}'), subtitle: Text('${order.department} • ${order.technician}'), trailing: Chip(label: Text(order.status.name)), children: [
        ListTile(title: Text(order.issueSummary)), ListTile(title: Text('Requested by: ${order.requestedBy}')),
        if (order.items.isNotEmpty) ...order.items.map((p) => ListTile(dense: true, leading: const Icon(Icons.build), title: Text(p.partName), subtitle: Text('Serial: ${p.serialNumber} • Qty: ${p.quantity}'))),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => PdfExportService.workOrder(order), icon: const Icon(Icons.picture_as_pdf), label: const Text('Print / Export PDF'))),
      ]));
    })),
  ])));
}
