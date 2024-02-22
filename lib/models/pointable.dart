mixin Pointable {
  double? lat;
  double? lon;

  pointFromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toDouble();
    lon = json['lon']?.toDouble();
  }
}
