import 'dart:convert';

enum VehicleStatus { available, garage, spare, inspection }

enum WorkOrderStatus { pending, inProgress, completed, onHold }

enum AccidentStatus { open, investigating, resolved }

class AppData {
  final List<Vehicle> vehicles;
  final List<GarageDepartment> garageDepartments;
  final List<CompanyDepartment> companyDepartments;
  final List<WorkOrder> workOrders;
  final List<AccidentReport> accidentReports;

  AppData({
    this.vehicles = const [],
    this.garageDepartments = const [],
    this.companyDepartments = const [],
    this.workOrders = const [],
    this.accidentReports = const [],
  });

  Map<String, dynamic> toMap() => {
        'vehicles': vehicles.map((e) => e.toMap()).toList(),
        'garageDepartments': garageDepartments.map((e) => e.toMap()).toList(),
        'companyDepartments': companyDepartments.map((e) => e.toMap()).toList(),
        'workOrders': workOrders.map((e) => e.toMap()).toList(),
        'accidentReports': accidentReports.map((e) => e.toMap()).toList(),
      };

  factory AppData.fromMap(Map<String, dynamic> map) {
    return AppData(
      vehicles: (map['vehicles'] as List? ?? [])
          .map((item) => Vehicle.fromMap(item as Map<String, dynamic>))
          .toList(),
      garageDepartments: (map['garageDepartments'] as List? ?? [])
          .map((item) => GarageDepartment.fromMap(item as Map<String, dynamic>))
          .toList(),
      companyDepartments: (map['companyDepartments'] as List? ?? [])
          .map((item) => CompanyDepartment.fromMap(item as Map<String, dynamic>))
          .toList(),
      workOrders: (map['workOrders'] as List? ?? [])
          .map((item) => WorkOrder.fromMap(item as Map<String, dynamic>))
          .toList(),
      accidentReports: (map['accidentReports'] as List? ?? [])
          .map((item) => AccidentReport.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AppData.fromJson(String source) => AppData.fromMap(jsonDecode(source));
}

class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final VehicleStatus status;
  final String driverName;
  final String driverDepartment;
  final String assignedDepartment;
  final int mileage;
  final String vin;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.status,
    required this.driverName,
    required this.driverDepartment,
    required this.assignedDepartment,
    required this.mileage,
    required this.vin,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'plateNumber': plateNumber,
        'make': make,
        'model': model,
        'year': year,
        'status': status.name,
        'driverName': driverName,
        'driverDepartment': driverDepartment,
        'assignedDepartment': assignedDepartment,
        'mileage': mileage,
        'vin': vin,
      };

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
        id: map['id'] ?? '',
        plateNumber: map['plateNumber'] ?? '',
        make: map['make'] ?? '',
        model: map['model'] ?? '',
        year: map['year'] ?? 0,
        status: VehicleStatus.values.firstWhere(
          (value) => value.name == (map['status'] ?? VehicleStatus.available.name),
          orElse: () => VehicleStatus.available,
        ),
        driverName: map['driverName'] ?? '',
        driverDepartment: map['driverDepartment'] ?? '',
        assignedDepartment: map['assignedDepartment'] ?? '',
        mileage: map['mileage'] ?? 0,
        vin: map['vin'] ?? '',
      );
}

class GarageDepartment {
  final String id;
  final String name;
  final bool isActive;

  GarageDepartment({
    required this.id,
    required this.name,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'isActive': isActive,
      };

  factory GarageDepartment.fromMap(Map<String, dynamic> map) => GarageDepartment(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        isActive: map['isActive'] ?? true,
      );
}

class CompanyDepartment {
  final String id;
  final String name;
  final bool isActive;

  CompanyDepartment({
    required this.id,
    required this.name,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'isActive': isActive,
      };

  factory CompanyDepartment.fromMap(Map<String, dynamic> map) => CompanyDepartment(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        isActive: map['isActive'] ?? true,
      );
}

class PartUsage {
  final String partName;
  final String serialNumber;
  final int quantity;

  PartUsage({
    required this.partName,
    required this.serialNumber,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'partName': partName,
        'serialNumber': serialNumber,
        'quantity': quantity,
      };

  factory PartUsage.fromMap(Map<String, dynamic> map) => PartUsage(
        partName: map['partName'] ?? '',
        serialNumber: map['serialNumber'] ?? '',
        quantity: map['quantity'] ?? 0,
      );
}

class WorkOrder {
  final String id;
  final String workOrderNumber;
  final String vehiclePlate;
  final String vehicleId;
  final String vehicleMake;
  final String vehicleModel;
  final String issueSummary;
  final String requestedBy;
  final String department;
  final String technician;
  final WorkOrderStatus status;
  final DateTime createdAt;
  final List<PartUsage> items;

  WorkOrder({
    required this.id,
    required this.workOrderNumber,
    required this.vehiclePlate,
    required this.vehicleId,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.issueSummary,
    required this.requestedBy,
    required this.department,
    required this.technician,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workOrderNumber': workOrderNumber,
        'vehiclePlate': vehiclePlate,
        'vehicleId': vehicleId,
        'vehicleMake': vehicleMake,
        'vehicleModel': vehicleModel,
        'issueSummary': issueSummary,
        'requestedBy': requestedBy,
        'department': department,
        'technician': technician,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((item) => item.toMap()).toList(),
      };

  factory WorkOrder.fromMap(Map<String, dynamic> map) => WorkOrder(
        id: map['id'] ?? '',
        workOrderNumber: map['workOrderNumber'] ?? 'GRG-0',
        vehiclePlate: map['vehiclePlate'] ?? '',
        vehicleId: map['vehicleId'] ?? '',
        vehicleMake: map['vehicleMake'] ?? '',
        vehicleModel: map['vehicleModel'] ?? '',
        issueSummary: map['issueSummary'] ?? '',
        requestedBy: map['requestedBy'] ?? '',
        department: map['department'] ?? '',
        technician: map['technician'] ?? '',
        status: WorkOrderStatus.values.firstWhere(
          (value) => value.name == (map['status'] ?? WorkOrderStatus.pending.name),
          orElse: () => WorkOrderStatus.pending,
        ),
        createdAt: DateTime.tryParse(map['createdAt'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
        items: ((map['items'] as List?) ?? [])
            .map((item) => PartUsage.fromMap(item as Map<String, dynamic>))
            .toList(),
      );
}

class AccidentReport {
  final String id;
  final String reportNumber;
  final String vehiclePlate;
  final String vehicleId;
  final String driverName;
  final String description;
  final String severity;
  final AccidentStatus status;
  final DateTime createdAt;
  final List<String> imagePaths;

  AccidentReport({
    required this.id,
    required this.reportNumber,
    required this.vehiclePlate,
    required this.vehicleId,
    required this.driverName,
    required this.description,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.imagePaths = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'reportNumber': reportNumber,
        'vehiclePlate': vehiclePlate,
        'vehicleId': vehicleId,
        'driverName': driverName,
        'description': description,
        'severity': severity,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'imagePaths': imagePaths,
      };

  factory AccidentReport.fromMap(Map<String, dynamic> map) => AccidentReport(
        id: map['id'] ?? '',
        reportNumber: map['reportNumber'] ?? 'ACC-0',
        vehiclePlate: map['vehiclePlate'] ?? '',
        vehicleId: map['vehicleId'] ?? '',
        driverName: map['driverName'] ?? '',
        description: map['description'] ?? '',
        severity: map['severity'] ?? 'Low',
        status: AccidentStatus.values.firstWhere(
          (value) => value.name == (map['status'] ?? AccidentStatus.open.name),
          orElse: () => AccidentStatus.open,
        ),
        createdAt: DateTime.tryParse(map['createdAt'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
        imagePaths: (map['imagePaths'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}
