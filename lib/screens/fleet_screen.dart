import 'package:flutter/material.dart';

import '../models/models.dart';

class FleetScreen extends StatelessWidget {
  final AppData appData;
  final Future<void> Function() onChanged;

  const FleetScreen({
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
            const Text('Fleet Vehicles', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: appData.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = appData.vehicles[index];
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
