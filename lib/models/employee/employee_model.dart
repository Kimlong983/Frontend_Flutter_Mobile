/// Employee schema (response) / EmployeeReq (request body).
class EmployeeModel {
  final int? id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String? gender; // MALE | FEMALE | OTHER
  final DateTime? dateOfBirth;
  final String email;
  final String phoneNumber;
  final String? position;
  final String? department;
  final double? salary;
  final DateTime? hireDate;
  final String? address;
  final String? photoUrl;
  final String status; // ACT | INA

  EmployeeModel({
    this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    this.position,
    this.department,
    this.salary,
    this.hireDate,
    this.address,
    this.photoUrl,
    this.status = "ACT",
  });

  String get fullName => "$firstName $lastName".trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : "";
    final l = lastName.isNotEmpty ? lastName[0] : "";
    final result = "$f$l".toUpperCase();
    return result.isEmpty ? "E" : result;
  }

  bool get isActive => status != "INA";
  bool get hasPhoto => photoUrl != null && photoUrl!.startsWith('http');

  /// "Position · Department", skipping empty parts.
  String get jobTitle => [position, department].where((s) => s != null && s.isNotEmpty).join(" · ");

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) => value == null ? null : DateTime.tryParse(value.toString());

    return EmployeeModel(
      id: (json['id'] as num?)?.toInt(),
      employeeCode: json['employeeCode']?.toString() ?? "",
      firstName: json['firstName']?.toString() ?? "",
      lastName: json['lastName']?.toString() ?? "",
      gender: json['gender']?.toString(),
      dateOfBirth: parseDate(json['dateOfBirth']),
      email: json['email']?.toString() ?? "",
      phoneNumber: json['phoneNumber']?.toString() ?? "",
      position: json['position']?.toString(),
      department: json['department']?.toString(),
      salary: (json['salary'] as num?)?.toDouble(),
      hireDate: parseDate(json['hireDate']),
      address: json['address']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      status: json['status']?.toString() ?? "ACT",
    );
  }

  /// EmployeeReq body for POST /api/employees and PUT /api/employees/{id}.
  Map<String, dynamic> toRequestJson() {
    String? nonEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

    return {
      'employeeCode': employeeCode,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': formatDate(dateOfBirth),
      'email': email,
      'phoneNumber': phoneNumber,
      'position': nonEmpty(position),
      'department': nonEmpty(department),
      'salary': salary,
      'hireDate': formatDate(hireDate),
      'address': nonEmpty(address),
      'photoUrl': nonEmpty(photoUrl),
      'status': status,
    };
  }
}
