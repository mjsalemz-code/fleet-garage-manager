import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  final AppData appData;
  final Future<void> Function() onRefresh;

  const HomeScreen({
    super.key,
    required this.appData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final available = appData.vehicles.where((v) => v.status == VehicleStatus.available).length;
    final garage = appData.vehicles.where((v) => v.status == VehicleStatus.garage).length;
    final spare = appData.vehicles.where((v) => v.status == VehicleStatus.spare).length;
    final inspection = appData.vehicles.where((v) => v.status == VehicleStatus.inspection).length;

    final statusData = [
      (label: 'Available', value: available.toDouble()),
      (label: 'Garage', value: garage.toDouble()),
      (label: 'Spare', value: spare.toDouble()),
      (label: 'Inspection', value: inspection.toDouble()),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Main Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                FilledButton.icon(
                  onPressed: () async => onRefresh(),
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                _StatCard(title: 'Vehicles', value: appData.vehicles.length.toString(), icon: Icons.local_shipping_rounded),
                _StatCard(title: 'Available', value: available.toString(), icon: Icons.check_circle_rounded),
                _StatCard(title: 'Work Orders', value: appData.workOrders.length.toString(), icon: Icons.build_rounded),
                _StatCard(title: 'Accidents', value: appData.accidentReports.length.toString(), icon: Icons.warning_amber_rounded),
              ],
            ),
            const SizedBox(height: 24),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              children: [
                _AnalysisCard(
                  title: 'Fleet Status Overview',
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: ((statusData.map((e) => e.value).reduce((max, value) => max > value ? max : value)) + 2),
                        barGroups: statusData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: item.value,
                                color: const Color(0xFF38BDF8),
                                width: 24,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= statusData.length) {
                                  return const SizedBox();
                                }
                                return Text(statusData[index].label, style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _AnalysisCard(
                  title: 'System Summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MiniDetail(label: 'Garage Departments', value: appData.garageDepartments.length.toString()),
                      _MiniDetail(label: 'Company Departments', value: appData.companyDepartments.length.toString()),
                      _MiniDetail(label: 'Open Work Orders', value: appData.workOrders.length.toString()),
                      _MiniDetail(label: 'Open Accidents', value: appData.accidentReports.length.toString()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Recent Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _OverviewList(
              workOrders: appData.workOrders,
              accidentReports: appData.accidentReports,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111827),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF7DD3FC)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnalysisCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111827),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _MiniDetail extends StatelessWidget {
  final String label;
  final String value;

  const _MiniDetail({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OverviewList extends StatelessWidget {
  final List<WorkOrder> workOrders;
  final List<AccidentReport> accidentReports;

  const _OverviewList({
    super.key,
    required this.workOrders,
    required this.accidentReports,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (final order in workOrders.take(4)) {
      items.add(
        ListTile(
          leading: const Icon(Icons.build_rounded),
          title: Text(order.workOrderNumber),
          subtitle: Text('${order.vehiclePlate} • ${order.department}'),
          trailing: Text(order.status.name),
        ),
      );
    }

    for (final accident in accidentReports.take(2)) {
      items.add(
        ListTile(
          leading: const Icon(Icons.warning_amber_rounded),
          title: Text(accident.reportNumber),
          subtitle: Text('${accident.vehiclePlate} • ${accident.driverName}'),
          trailing: Text(accident.status.name),
        ),
      );
    }

    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('No recent activity available yet.'),
        ),
      );
    }

    return Card(
      child: Column(children: items),
    );
  }
}
