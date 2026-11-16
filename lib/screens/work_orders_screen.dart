import 'package:flutter/material.dart';

import '../models/models.dart';

class FleetScreen extends StatefulWidget {
  final AppData appData;
  final ValueChanged<AppData> onChanged;

  const FleetScreen({
    super.key,
    required this.appData,
    required this.onChanged,
  });

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _selectedStatus;

  List<Vehicle> get filteredVehicles {
    final query = _searchController.text.trim().toLowerCase();
    return widget.appData.vehicles.where((vehicle) {
      final matchesQuery = query.isEmpty ||
          vehicle.plateNumber.toLowerCase().contains(query) ||
          vehicle.make.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query) ||
          vehicle.driverName.toLowerCase().contains(query) ||
          vehicle.driverDepartment.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == null || vehicle.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _showAddVehicleDialog() {
    final formKey = GlobalKey<FormState>();
    final plateController = TextEditingController();
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final driverNameController = TextEditingController();
    final driverDepartmentController = TextEditingController();
    final assignedDepartmentController = TextEditingController();
    final mileageController = TextEditingController();
    final vinController = TextEditingController();

    VehicleStatus status = VehicleStatus.available;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Vehicle'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: plateController,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Plate Number'),
                  ),
                  TextFormField(
                    controller: makeController,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Make'),
                  ),
                  TextFormField(
                    controller: modelController,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Model'),
                  ),
                  TextFormField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                  TextFormField(
                    controller: driverNameController,
                    decoration: const InputDecoration(labelText: 'Driver Name'),
                  ),
                  TextFormField(
                    controller: driverDepartmentController,
                    decoration: const InputDecoration(labelText: 'Driver Department'),
                  ),
                  TextFormField(
                    controller: assignedDepartmentController,
                    decoration: const InputDecoration(labelText: 'Assigned Department'),
                  ),
                  TextFormField(
                    controller: mileageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Mileage'),
                  ),
                  TextFormField(
                    controller: vinController,
                    decoration: const InputDecoration(labelText: 'VIN'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<VehicleStatus>(
                    value: status,
                    items: VehicleStatus.values
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
                  final newVehicle = Vehicle(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    plateNumber: plateController.text.trim(),
                    make: makeController.text.trim(),
                    model: modelController.text.trim(),
                    year: int.tryParse(yearController.text.trim()) ?? DateTime.now().year,
                    status: status,
                    driverName: driverNameController.text.trim(),
                    driverDepartment: driverDepartmentController.text.trim(),
                    assignedDepartment: assignedDepartmentController.text.trim(),
                    mileage: int.tryParse(mileageController.text.trim()) ?? 0,
                    vin: vinController.text.trim(),
                  );

                  final updated = AppData(
                    vehicles: [...widget.appData.vehicles, newVehicle],
                    garageDepartments: widget.appData.garageDepartments,
                    companyDepartments: widget.appData.companyDepartments,
                    workOrders: widget.appData.workOrders,
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
            const Text('Fleet Vehicles', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search vehicle by plate, make, driver...',
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
                  onPressed: _showAddVehicleDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
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
                ...VehicleStatus.values.map(
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
            const SizedBox(height: 18),
            Expanded(
              child: filteredVehicles.isEmpty
                  ? const Center(child: Text('No vehicles found'))
                  : ListView.builder(
                      itemCount: filteredVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = filteredVehicles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.local_shipping_rounded),
                            ),
                            title: Text('${vehicle.make} ${vehicle.model} • ${vehicle.plateNumber}'),
                            subtitle: Text('Driver: ${vehicle.driverName} • Dept: ${vehicle.driverDepartment}'),
                            trailing: Chip(
                              label: Text(vehicle.status.name),
                              backgroundColor: _statusColor(vehicle.status),
                            ),
                            children: [
                              ListTile(
                                title: Text('Assigned Department: ${vehicle.assignedDepartment}'),
                              ),
                              ListTile(
                                title: Text('Mileage: ${vehicle.mileage}'),
                              ),
                              ListTile(
                                title: Text('VIN: ${vehicle.vin}'),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit_rounded),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.delete_rounded),
                                    label: const Text('Delete'),
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

  Color _statusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return Colors.green.withOpacity(0.2);
      case VehicleStatus.garage:
        return Colors.amber.withOpacity(0.2);
      case VehicleStatus.spare:
        return Colors.blueGrey.withOpacity(0.2);
      case VehicleStatus.inspection:
        return Colors.purple.withOpacity(0.2);
    }
  }
}
