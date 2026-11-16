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
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: appData.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = appData.vehicles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.local_shipping_rounded),
                      ),
                      title: Text('${vehicle.make} ${vehicle.model} (${vehicle.plateNumber})'),
                      subtitle: Text('Driver: ${vehicle.driverName} • Department: ${vehicle.driverDepartment}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(vehicle.status.name),
                          Text(vehicle.assignedDepartment),
                        ],
                      ),
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
