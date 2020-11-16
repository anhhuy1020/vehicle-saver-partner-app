
import 'package:json_annotation/json_annotation.dart';

part 'place_model.g.dart';

@JsonSerializable(nullable: false)
class Place {
  String name;
  String formattedAddress;
  double lat;
  double lng;

  Place({this.name, this.formattedAddress, this.lat, this.lng});

  factory Place.fromJson(Map<String, dynamic> map) {
    return Place(
      name: map['name'],
      formattedAddress: map['formatted_address'],
      lat: map['geometry']['location']['lat'],
      lng: map['geometry']['location']['lng'],
    );
  }

  static List<Place> parseLocationList(map) {
    var list = map['results'] as List;
    return list.map((movie) => Place.fromJson(movie)).toList();
  }

  @override
  String toString() {
    return 'Place{name: $name, formattedAddress: $formattedAddress, lat: $lat, lng: $lng}';
  }
}
