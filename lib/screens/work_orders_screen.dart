import 'package:flutter/material.dart';

import '../models/models.dart';

class WorkOrdersScreen extends StatelessWidget {
  final AppData appData;
  final Future<void> Function() onChanged;

  const WorkOrdersScreen({
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
            const Text('Work Orders', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sequence format: GRG-1, GRG-2, ...', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.assignment_add_rounded),
              label: const Text('New Work Order'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: appData.workOrders.length,
                itemBuilder: (context, index) {
                  final order = appData.workOrders[index];
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
