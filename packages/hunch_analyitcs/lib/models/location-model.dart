class Location {
  String? region;
  String? country;
  String? city;

  Location({this.region, this.country, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    region = json['region'];
    country = json['country'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['region'] = region;
    data['country'] = country;
    data['city'] = city;
    return data;
  }
}
