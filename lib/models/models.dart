import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'models/models.dart';
import 'screens/home_screen.dart';
import 'screens/fleet_screen.dart';
import 'screens/work_orders_screen.dart';
import 'screens/accident_reports_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_data_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const FleetGarageApp());
}

class FleetGarageApp extends StatelessWidget {
  const FleetGarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet Garage Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF111827),
        ),
      ),
      home: const FleetGarageHomePage(),
    );
  }
}

class FleetGarageHomePage extends StatefulWidget {
  const FleetGarageHomePage({super.key});

  @override
  State<FleetGarageHomePage> createState() => _FleetGarageHomePageState();
}

class _FleetGarageHomePageState extends State<FleetGarageHomePage> {
  final LocalDataStore _store = LocalDataStore();
  final Uuid _uuid = const Uuid();

  late AppData _appData;
  int _selectedIndex = 0;
  bool _menuExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _store.load();
    setState(() {
      _appData = data;
    });
  }

  Future<void> _saveData() async {
    await _store.save(_appData);
  }

  void _addSampleData() {
    setState(() {
      _appData = AppData(
        vehicles: [
          Vehicle(
            id: _uuid.v4(),
            plateNumber: 'ABC-1234',
            make: 'Toyota',
            model: 'Hiace',
            year: 2022,
            status: VehicleStatus.available,
            driverName: 'Samir Ali',
            driverDepartment: 'Logistics',
            assignedDepartment: 'Operations',
            mileage: 45678,
            vin: 'VIN-01',
          ),
          Vehicle(
            id: _uuid.v4(),
            plateNumber: 'MJD-9087',
            make: 'Ford',
            model: 'Transit',
            year: 2021,
            status: VehicleStatus.garage,
            driverName: 'Ibrahim Noor',
            driverDepartment: 'Maintenance',
            assignedDepartment: 'Operations',
            mileage: 67340,
            vin: 'VIN-02',
          ),
        ],
        garageDepartments: [
          GarageDepartment(id: _uuid.v4(), name: 'Mechanical', isActive: true),
          GarageDepartment(id: _uuid.v4(), name: 'Electrical', isActive: true),
          GarageDepartment(id: _uuid.v4(), name: 'Cooling System', isActive: true),
          GarageDepartment(id: _uuid.v4(), name: 'Oil Services', isActive: true),
          GarageDepartment(id: _uuid.v4(), name: 'Paint & Denting', isActive: true),
          GarageDepartment(id: _uuid.v4(), name: 'Tires', isActive: true),
        ],
        companyDepartments: [
          CompanyDepartment(id: _uuid.v4(), name: 'Operations', isActive: true),
          CompanyDepartment(id: _uuid.v4(), name: 'Logistics', isActive: true),
          CompanyDepartment(id: _uuid.v4(), name: 'Fleet Administration', isActive: true),
        ],
        workOrders: [
          WorkOrder(
            id: _uuid.v4(),
            workOrderNumber: 'GRG-1',
            vehiclePlate: 'MJD-9087',
            vehicleId: _uuid.v4(),
            vehicleMake: 'Ford',
            vehicleModel: 'Transit',
            issueSummary: 'Brake inspection and replacement',
            requestedBy: 'Fleet admin',
            department: 'Mechanical',
            technician: 'Ali Hassan',
            status: WorkOrderStatus.inProgress,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            items: [
              PartUsage(partName: 'Brake Pad', serialNumber: 'BP-112', quantity: 2),
            ],
          ),
        ],
        accidentReports: [
          AccidentReport(
            id: _uuid.v4(),
            reportNumber: 'ACC-1',
            vehiclePlate: 'ABC-1234',
            vehicleId: _uuid.v4(),
            driverName: 'Samir Ali',
            description: 'Minor front bumper impact while parking',
            severity: 'Medium',
            status: AccidentStatus.open,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            imagePaths: const [],
          ),
        ],
      );
      _saveData();
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(appData: _appData, onRefresh: _saveData);
      case 1:
        return FleetScreen(appData: _appData, onChanged: _saveData);
      case 2:
        return WorkOrdersScreen(appData: _appData, onChanged: _saveData);
      case 3:
        return AccidentReportsScreen(appData: _appData, onChanged: _saveData);
      case 4:
        return SettingsScreen(appData: _appData, onChanged: _saveData);
      default:
        return HomeScreen(appData: _appData, onRefresh: _saveData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (_appData.vehicles.isEmpty && _appData.workOrders.isEmpty && _appData.accidentReports.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dashboard_customize_rounded, size: 72),
              const SizedBox(height: 16),
              const Text('No system data yet', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 12),
              const Text('Tap below to initialize sample fleet and maintenance data.'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _addSampleData,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Initialize Demo Data'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Garage Manager'),
        leading: isWide
            ? IconButton(
                onPressed: () => setState(() => _menuExpanded = !_menuExpanded),
                icon: const Icon(Icons.menu_rounded),
              )
            : null,
        actions: [
          IconButton(
            onPressed: _saveData,
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save Data',
          ),
          IconButton(
            onPressed: _addSampleData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Demo Data',
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _menuExpanded ? 220 : 84,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                border: const Border(right: BorderSide(color: Colors.white12)),
              ),
              child: NavigationRail(
                extended: _menuExpanded,
                backgroundColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (v) => setState(() => _selectedIndex = v),
                labelType: _menuExpanded
                    ? NavigationRailLabelType.expanded
                    : NavigationRailLabelType.none,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_rounded),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_shipping_rounded),
                    label: Text('Fleet'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.build_rounded),
                    label: Text('Work Orders'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.warning_amber_rounded),
                    label: Text('Accidents'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_rounded),
                    label: Text('Settings'),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildPage()),
        ],
      ),
      drawer: !isWide
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF1E293B)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.miscellaneous_services_rounded, size: 40),
                        SizedBox(height: 8),
                        Text('Fleet Garage', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                  _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0, selected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0)),
                  _NavItem(icon: Icons.local_shipping_rounded, label: 'Fleet', index: 1, selected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1)),
                  _NavItem(icon: Icons.build_rounded, label: 'Work Orders', index: 2, selected: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2)),
                  _NavItem(icon: Icons.warning_amber_rounded, label: 'Accidents', index: 3, selected: _selectedIndex == 3, onTap: () => setState(() => _selectedIndex = 3)),
                  _NavItem(icon: Icons.settings_rounded, label: 'Settings', index: 4, selected: _selectedIndex == 4, onTap: () => setState(() => _selectedIndex = 4)),
                ],
              ),
            )
          : null,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
