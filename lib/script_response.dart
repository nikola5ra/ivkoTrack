class ScriptResponse {
  final String? status;
  final String? message;
  final String? name;
  final String? model;
  final String? serialNumber;

  const ScriptResponse({
    required this.status,
    required this.message,
    required this.name,
    required this.model,
    required this.serialNumber,
  });

  factory ScriptResponse.fromJson(Map<String, dynamic> json) {
    return ScriptResponse(
      status: json['status'],
      message: json['message'],
      name: json['name'],
      model: json['model'],
      serialNumber: json['serialNumber'],
    );
  }
}
