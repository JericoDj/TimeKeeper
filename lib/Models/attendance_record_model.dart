class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime timeIn;
  final DateTime? timeOut;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.timeIn,
    this.timeOut,
  });
}
