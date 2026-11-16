import 'package:flutter/material.dart';

import '../models/models.dart';

class WorkOrdersScreen extends StatefulWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;

  const WorkOrdersScreen({
    super.key,
    required this.appData,
    required this.onChanged,
  });

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  WorkOrderStatus? _selectedStatus;

  List<WorkOrder> get filteredWorkOrders {
    final query = _searchController.text.trim().toLowerCase();
    return widget.appData.workOrders.where((order) {
      final matchesQuery = query.isEmpty ||
          order.workOrderNumber.toLowerCase().contains(query) ||
          order.vehiclePlate.toLowerCase().contains(query) ||
          order.technician.toLowerCase().contains(query) ||
          order.department.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _showAddWorkOrderDialog() {
    final formKey = GlobalKey<FormState>();
    final vehiclePlateController = TextEditingController();
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final issueController = TextEditingController();
    final requestedByController = TextEditingController();
    final departmentController = TextEditingController(text: 'Mechanical');
    final technicianController = TextEditingController();
    final partNameController = TextEditingController();
    final serialController = TextEditingController();
    final quantityController = TextEditingController(text: '1');

    WorkOrderStatus status = WorkOrderStatus.pending;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Work Order'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: vehiclePlateController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      decoration: const InputDecoration(labelText: 'Vehicle Plate'),
                    ),
                    TextFormField(
                      controller: makeController,
                      decoration: const InputDecoration(labelText: 'Make'),
                    ),
                    TextFormField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    TextFormField(
                      controller: issueController,
                      maxLines: 3,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      decoration: const InputDecoration(labelText: 'Issue Summary'),
                    ),
                    TextFormField(
                      controller: requestedByController,
                      decoration: const InputDecoration(labelText: 'Requested By'),
                    ),
                    TextFormField(
                      controller: departmentController,
                      decoration: const InputDecoration(labelText: 'Department'),
                    ),
                    TextFormField(
                      controller: technicianController,
                      decoration: const InputDecoration(labelText: 'Technician'),
                    ),
                    DropdownButtonFormField<WorkOrderStatus>(
                      value: status,
                      items: WorkOrderStatus.values
                          .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          status = value;
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Parts Used', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextFormField(
                      controller: partNameController,
                      decoration: const InputDecoration(labelText: 'Part Name'),
                    ),
                    TextFormField(
                      controller: serialController,
                      decoration: const InputDecoration(labelText: 'Serial Number'),
                    ),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final nextNumber = widget.appData.nextWorkOrderSequence();
                  final newOrder = WorkOrder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    workOrderNumber: 'GRG-$nextNumber',
                    vehiclePlate: vehiclePlateController.text.trim(),
                    vehicleId: DateTime.now().millisecondsSinceEpoch.toString(),
                    vehicleMake: makeController.text.trim(),
                    vehicleModel: modelController.text.trim(),
                    issueSummary: issueController.text.trim(),
                    requestedBy: requestedByController.text.trim(),
                    department: departmentController.text.trim(),
                    technician: technicianController.text.trim(),
                    status: status,
                    createdAt: DateTime.now(),
                    items: [
                      PartUsage(
                        partName: partNameController.text.trim().isEmpty ? 'N/A' : partNameController.text.trim(),
                        serialNumber: serialController.text.trim(),
                        quantity: int.tryParse(quantityController.text.trim()) ?? 1,
                      ),
                    ],
                  );

                  final updated = AppData(
                    vehicles: widget.appData.vehicles,
                    garageDepartments: widget.appData.garageDepartments,
                    companyDepartments: widget.appData.companyDepartments,
                    workOrders: [...widget.appData.workOrders, newOrder],
                    accidentReports: widget.appData.accidentReports,
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
            const Text('Work Orders', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sequence format: GRG-1, GRG-2, ...', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search work order or plate...',
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
                  onPressed: _showAddWorkOrderDialog,
                  icon: const Icon(Icons.assignment_add_rounded),
                  label: const Text('New'),
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
                ...WorkOrderStatus.values.map(
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
              child: filteredWorkOrders.isEmpty
                  ? const Center(child: Text('No work orders found'))
                  : ListView.builder(
                      itemCount: filteredWorkOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredWorkOrders[index];
                        final partsText = order.items.isEmpty
                            ? 'No parts recorded'
                            : order.items.map((part) => '${part.partName} (${part.quantity})').join(', ');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text('${order.workOrderNumber} • ${order.vehiclePlate}'),
                            subtitle: Text('${order.department} • ${order.technician}'),
                            trailing: Chip(label: Text(order.status.name)),
                            children: [
                              ListTile(title: Text(order.issueSummary)),
                              ListTile(title: Text('Requested by: ${order.requestedBy}')),
                              ListTile(title: Text('Vehicle: ${order.vehicleMake} ${order.vehicleModel}')),
                              ListTile(
                                title: const Text('Parts Used'),
                                subtitle: Text(partsText),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.print_rounded),
                                    label: const Text('Print'),
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
