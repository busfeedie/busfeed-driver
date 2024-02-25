abstract class Model {
  final String id;
  final String appId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Model(
      {required this.id, required this.appId, this.createdAt, this.updatedAt});

  Model.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        appId = json['app_id'].toString(),
        createdAt = parseDateTime(json['created_at']),
        updatedAt = parseDateTime(json['updated_at']);

  static parseDateTime(String? dateTime) {
    return dateTime != null ? DateTime.parse(dateTime) : null;
  }
}
