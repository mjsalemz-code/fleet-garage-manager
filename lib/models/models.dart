import 'dart:convert';

class AppData {
  final List<Vehicle> vehicles;
  final List<GarageDepartment> garageDepartments;
  final List<CompanyDepartment> companyDepartments;
  final List<WorkOrder> workOrders;
  final List<AccidentReport> accidentReports;
  final List<InventoryPart> inventoryParts;

  AppData({
    this.vehicles = const [],
    this.garageDepartments = const [],
    this.companyDepartments = const [],
    this.workOrders = const [],
    this.accidentReports = const [],
    this.inventoryParts = const [],
  });

  Map<String, dynamic> toMap() => {
        'backupVersion': 1,
        'vehicles': vehicles.map((e) => e.toMap()).toList(),
        'garageDepartments': garageDepartments.map((e) => e.toMap()).toList(),
        'companyDepartments': companyDepartments.map((e) => e.toMap()).toList(),
        'workOrders': workOrders.map((e) => e.toMap()).toList(),
        'accidentReports': accidentReports.map((e) => e.toMap()).toList(),
        'inventoryParts': inventoryParts.map((e) => e.toMap()).toList(),
      };

  factory AppData.fromMap(Map<String, dynamic> map) => AppData(
        vehicles: ((map['vehicles'] as List?) ?? [])
            .map((item) => Vehicle.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        garageDepartments: ((map['garageDepartments'] as List?) ?? [])
            .map((item) => GarageDepartment.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        companyDepartments: ((map['companyDepartments'] as List?) ?? [])
            .map((item) => CompanyDepartment.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        workOrders: ((map['workOrders'] as List?) ?? [])
            .map((item) => WorkOrder.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        accidentReports: ((map['accidentReports'] as List?) ?? [])
            .map((item) => AccidentReport.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
        inventoryParts: ((map['inventoryParts'] as List?) ?? [])
            .map((item) => InventoryPart.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList(),
      );

  String toJson() => const JsonEncoder.withIndent('  ').convert(toMap());
  factory AppData.fromJson(String source) => AppData.fromMap(jsonDecode(source) as Map<String, dynamic>);

  int nextWorkOrderSequence() => _nextSequence(workOrders.map((e) => e.workOrderNumber), 'GRG-');
  int nextAccidentSequence() => _nextSequence(accidentReports.map((e) => e.reportNumber), 'ACC-');

  static int _nextSequence(Iterable<String> values, String prefix) {
    var max = 0;
    for (final value in values) {
      final number = int.tryParse(value.replaceFirst(prefix, '')) ?? 0;
      if (number > max) max = number;
    }
    return max + 1;
  }
}

enum VehicleStatus { available, garage, spare, inspection }
enum WorkOrderStatus { pending, inProgress, completed, onHold }
enum AccidentStatus { open, investigating, resolved }

class Vehicle {
  final String id, plateNumber, make, model, driverName, driverDepartment, assignedDepartment, vin;
  final int year, mileage;
  final VehicleStatus status;

  Vehicle({required this.id, required this.plateNumber, required this.make, required this.model,
    required this.year, required this.status, required this.driverName, required this.driverDepartment,
    required this.assignedDepartment, required this.mileage, required this.vin});

  Map<String, dynamic> toMap() => {'id': id, 'plateNumber': plateNumber, 'make': make, 'model': model,
    'year': year, 'status': status.name, 'driverName': driverName, 'driverDepartment': driverDepartment,
    'assignedDepartment': assignedDepartment, 'mileage': mileage, 'vin': vin};

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
    id: map['id'] ?? '', plateNumber: map['plateNumber'] ?? '', make: map['make'] ?? '',
    model: map['model'] ?? '', year: (map['year'] as num?)?.toInt() ?? 0,
    status: VehicleStatus.values.firstWhere((v) => v.name == map['status'], orElse: () => VehicleStatus.available),
    driverName: map['driverName'] ?? '', driverDepartment: map['driverDepartment'] ?? '',
    assignedDepartment: map['assignedDepartment'] ?? '', mileage: (map['mileage'] as num?)?.toInt() ?? 0,
    vin: map['vin'] ?? '');
}

class GarageDepartment {
  final String id, name;
  final bool isActive;
  GarageDepartment({required this.id, required this.name, required this.isActive});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'isActive': isActive};
  factory GarageDepartment.fromMap(Map<String, dynamic> map) => GarageDepartment(
    id: map['id'] ?? '', name: map['name'] ?? '', isActive: map['isActive'] ?? true);
}

class CompanyDepartment {
  final String id, name;
  final bool isActive;
  CompanyDepartment({required this.id, required this.name, required this.isActive});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'isActive': isActive};
  factory CompanyDepartment.fromMap(Map<String, dynamic> map) => CompanyDepartment(
    id: map['id'] ?? '', name: map['name'] ?? '', isActive: map['isActive'] ?? true);
}

class InventoryPart {
  final String id, partName, partNumber, serialNumber, supplier;
  final int quantityInStock, reorderLevel;
  InventoryPart({required this.id, required this.partName, required this.partNumber,
    required this.serialNumber, required this.supplier, required this.quantityInStock, required this.reorderLevel});
  Map<String, dynamic> toMap() => {'id': id, 'partName': partName, 'partNumber': partNumber,
    'serialNumber': serialNumber, 'supplier': supplier, 'quantityInStock': quantityInStock, 'reorderLevel': reorderLevel};
  factory InventoryPart.fromMap(Map<String, dynamic> map) => InventoryPart(
    id: map['id'] ?? '', partName: map['partName'] ?? '', partNumber: map['partNumber'] ?? '',
    serialNumber: map['serialNumber'] ?? '', supplier: map['supplier'] ?? '',
    quantityInStock: (map['quantityInStock'] as num?)?.toInt() ?? 0,
    reorderLevel: (map['reorderLevel'] as num?)?.toInt() ?? 0);
}

class PartUsage {
  final String partName, serialNumber;
  final int quantity;
  PartUsage({required this.partName, required this.serialNumber, required this.quantity});
  Map<String, dynamic> toMap() => {'partName': partName, 'serialNumber': serialNumber, 'quantity': quantity};
  factory PartUsage.fromMap(Map<String, dynamic> map) => PartUsage(
    partName: map['partName'] ?? '', serialNumber: map['serialNumber'] ?? '',
    quantity: (map['quantity'] as num?)?.toInt() ?? 0);
}

class WorkOrder {
  final String id, workOrderNumber, vehiclePlate, vehicleId, vehicleMake, vehicleModel;
  final String issueSummary, requestedBy, department, technician;
  final WorkOrderStatus status;
  final DateTime createdAt;
  final List<PartUsage> items;
  WorkOrder({required this.id, required this.workOrderNumber, required this.vehiclePlate,
    required this.vehicleId, required this.vehicleMake, required this.vehicleModel,
    required this.issueSummary, required this.requestedBy, required this.department,
    required this.technician, required this.status, required this.createdAt, this.items = const []});
  Map<String, dynamic> toMap() => {'id': id, 'workOrderNumber': workOrderNumber, 'vehiclePlate': vehiclePlate,
    'vehicleId': vehicleId, 'vehicleMake': vehicleMake, 'vehicleModel': vehicleModel,
    'issueSummary': issueSummary, 'requestedBy': requestedBy, 'department': department,
    'technician': technician, 'status': status.name, 'createdAt': createdAt.toIso8601String(),
    'items': items.map((item) => item.toMap()).toList()};
  factory WorkOrder.fromMap(Map<String, dynamic> map) => WorkOrder(
    id: map['id'] ?? '', workOrderNumber: map['workOrderNumber'] ?? 'GRG-0',
    vehiclePlate: map['vehiclePlate'] ?? '', vehicleId: map['vehicleId'] ?? '',
    vehicleMake: map['vehicleMake'] ?? '', vehicleModel: map['vehicleModel'] ?? '',
    issueSummary: map['issueSummary'] ?? '', requestedBy: map['requestedBy'] ?? '',
    department: map['department'] ?? '', technician: map['technician'] ?? '',
    status: WorkOrderStatus.values.firstWhere((v) => v.name == map['status'], orElse: () => WorkOrderStatus.pending),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    items: ((map['items'] as List?) ?? []).map((e) => PartUsage.fromMap(Map<String, dynamic>.from(e as Map))).toList());
}

class AccidentReport {
  final String id, reportNumber, vehiclePlate, vehicleId, driverName, description, severity;
  final AccidentStatus status;
  final DateTime createdAt;
  final List<String> imagePaths;
  AccidentReport({required this.id, required this.reportNumber, required this.vehiclePlate,
    required this.vehicleId, required this.driverName, required this.description, required this.severity,
    required this.status, required this.createdAt, this.imagePaths = const []});
  Map<String, dynamic> toMap() => {'id': id, 'reportNumber': reportNumber, 'vehiclePlate': vehiclePlate,
    'vehicleId': vehicleId, 'driverName': driverName, 'description': description, 'severity': severity,
    'status': status.name, 'createdAt': createdAt.toIso8601String(), 'imagePaths': imagePaths};
  factory AccidentReport.fromMap(Map<String, dynamic> map) => AccidentReport(
    id: map['id'] ?? '', reportNumber: map['reportNumber'] ?? 'ACC-0',
    vehiclePlate: map['vehiclePlate'] ?? '', vehicleId: map['vehicleId'] ?? '',
    driverName: map['driverName'] ?? '', description: map['description'] ?? '', severity: map['severity'] ?? 'Low',
    status: AccidentStatus.values.firstWhere((v) => v.name == map['status'], orElse: () => AccidentStatus.open),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    imagePaths: ((map['imagePaths'] as List?) ?? []).map((e) => e.toString()).toList());
}
