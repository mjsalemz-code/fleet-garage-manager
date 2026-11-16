import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/local_data_store.dart';

class SettingsScreen extends StatefulWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;
  const SettingsScreen({super.key, required this.appData, required this.onChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _uuid = const Uuid();
  final _store = LocalDataStore();
  bool _busy = false;

  void _replace({List<GarageDepartment>? garage, List<CompanyDepartment>? company, List<InventoryPart>? inventory}) {
    widget.onChanged(AppData(
      vehicles: widget.appData.vehicles,
      garageDepartments: garage ?? widget.appData.garageDepartments,
      companyDepartments: company ?? widget.appData.companyDepartments,
      workOrders: widget.appData.workOrders,
      accidentReports: widget.appData.accidentReports,
      inventoryParts: inventory ?? widget.appData.inventoryParts,
    ));
  }

  Future<void> _editDepartment({required bool garage, String? id, String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${id == null ? 'Add' : 'Edit'} ${garage ? 'Garage' : 'Company'} Department'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Department name')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save'))],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (garage) {
      final rows = [...widget.appData.garageDepartments];
      final index = rows.indexWhere((e) => e.id == id);
      if (index < 0) { rows.add(GarageDepartment(id: _uuid.v4(), name: name, isActive: true)); }
      else { rows[index] = GarageDepartment(id: id!, name: name, isActive: rows[index].isActive); }
      _replace(garage: rows);
    } else {
      final rows = [...widget.appData.companyDepartments];
      final index = rows.indexWhere((e) => e.id == id);
      if (index < 0) { rows.add(CompanyDepartment(id: _uuid.v4(), name: name, isActive: true)); }
      else { rows[index] = CompanyDepartment(id: id!, name: name, isActive: rows[index].isActive); }
      _replace(company: rows);
    }
  }

  Future<void> _editPart({InventoryPart? part}) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: part?.partName ?? '');
    final number = TextEditingController(text: part?.partNumber ?? '');
    final serial = TextEditingController(text: part?.serialNumber ?? '');
    final supplier = TextEditingController(text: part?.supplier ?? '');
    final quantity = TextEditingController(text: part?.quantityInStock.toString() ?? '0');
    final reorder = TextEditingController(text: part?.reorderLevel.toString() ?? '0');
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(part == null ? 'Add Inventory Part' : 'Edit Inventory Part'),
      content: SizedBox(width: 440, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Part name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: number, decoration: const InputDecoration(labelText: 'Part number')),
        TextFormField(controller: serial, decoration: const InputDecoration(labelText: 'Serial number')),
        TextFormField(controller: supplier, decoration: const InputDecoration(labelText: 'Supplier')),
        TextFormField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity in stock')),
        TextFormField(controller: reorder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Low-stock threshold')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Save'))],
    ));
    if (saved != true) return;
    final value = InventoryPart(id: part?.id ?? _uuid.v4(), partName: name.text.trim(), partNumber: number.text.trim(),
      serialNumber: serial.text.trim(), supplier: supplier.text.trim(), quantityInStock: int.tryParse(quantity.text) ?? 0,
      reorderLevel: int.tryParse(reorder.text) ?? 0);
    final rows = [...widget.appData.inventoryParts];
    final index = rows.indexWhere((e) => e.id == value.id);
    if (index < 0) rows.add(value); else rows[index] = value;
    _replace(inventory: rows);
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final bytes = Uint8List.fromList(utf8.encode(await _store.exportJson(widget.appData)));
      await FilePicker.platform.saveFile(fileName: 'fleet_backup_$stamp.json', bytes: bytes, type: FileType.custom, allowedExtensions: ['json']);
      _message('Backup exported.');
    } catch (error) { _message('Could not export backup: $error'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _importBackup() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
      if (result == null || result.files.single.bytes == null) return;
      final backup = AppData.fromJson(utf8.decode(result.files.single.bytes!));
      await _store.save(backup);
      widget.onChanged(backup);
      _message('Backup restored successfully.');
    } catch (error) { _message('Backup could not be restored. Check that the selected JSON file is valid. $error'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _confirmDelete(String title, VoidCallback onDelete) async {
    final yes = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text('Delete $title?'), content: const Text('This cannot be undone.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))]));
    if (yes == true) onDelete();
  }

  Widget _departmentSection<T>({required String title, required List<T> rows, required String Function(T) name,
      required String Function(T) id, required bool garage}) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        IconButton(onPressed: () => _editDepartment(garage: garage), icon: const Icon(Icons.add_circle_outline), tooltip: 'Add department')]),
      if (rows.isEmpty) const Text('No departments configured yet.') else ...rows.map((row) => ListTile(
        contentPadding: EdgeInsets.zero, leading: const Icon(Icons.account_tree_outlined), title: Text(name(row)),
        trailing: Wrap(spacing: 0, children: [IconButton(onPressed: () => _editDepartment(garage: garage, id: id(row), initial: name(row)), icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: () => _confirmDelete(name(row), () { if (garage) { _replace(garage: widget.appData.garageDepartments.where((e) => e.id != id(row)).toList()); }
            else { _replace(company: widget.appData.companyDepartments.where((e) => e.id != id(row)).toList()); } }), icon: const Icon(Icons.delete_outline))]),
      ))
    ])));
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Settings & Data', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    _departmentSection<GarageDepartment>(title: 'Garage Departments', rows: widget.appData.garageDepartments,
      name: (e) => e.name, id: (e) => e.id, garage: true),
    _departmentSection<CompanyDepartment>(title: 'Company Departments', rows: widget.appData.companyDepartments,
      name: (e) => e.name, id: (e) => e.id, garage: false),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('Parts Inventory (${widget.appData.inventoryParts.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        IconButton(onPressed: () => _editPart(), icon: const Icon(Icons.add_circle_outline), tooltip: 'Add part')]),
      if (widget.appData.inventoryParts.isEmpty) const Text('Add parts here to reuse them in maintenance records.') else ...widget.appData.inventoryParts.map((part) => ListTile(
        contentPadding: EdgeInsets.zero, leading: const Icon(Icons.inventory_2_outlined), title: Text(part.partName),
        subtitle: Text('${part.partNumber.isEmpty ? 'No part number' : part.partNumber} • Stock ${part.quantityInStock} • ${part.supplier}'),
        trailing: Wrap(children: [IconButton(onPressed: () => _editPart(part: part), icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: () => _confirmDelete(part.partName, () => _replace(inventory: widget.appData.inventoryParts.where((e) => e.id != part.id).toList())), icon: const Icon(Icons.delete_outline))]),
      )),
    ]))),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Offline Backup & Restore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6), const Text('Export a JSON backup for transfer between devices, or restore a previously exported backup.'),
      const SizedBox(height: 12), Wrap(spacing: 10, runSpacing: 8, children: [
        FilledButton.icon(onPressed: _busy ? null : _exportBackup, icon: const Icon(Icons.file_download_outlined), label: const Text('Export JSON')),
        OutlinedButton.icon(onPressed: _busy ? null : _importBackup, icon: const Icon(Icons.file_upload_outlined), label: const Text('Restore JSON')),
        if (_busy) const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ]),
    ]))),
    const Card(child: ListTile(leading: Icon(Icons.phone_android), title: Text('Offline-first storage'), subtitle: Text('Data stays on this device unless you export a backup.'))),
  ]));
}
