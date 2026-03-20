import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination_model.freezed.dart';
part 'destination_model.g.dart';

@freezed
abstract class Destination with _$Destination {
  const Destination._();

  const factory Destination({
    required String xid,
    required String name,
    String? description,
    String? imageUrl,
    required String category,
    required double latitude,
    required double longitude,
    String? address,
    String? url,
    String? wikipedia,
    String? osm,
    double? rate,
    String? highlight,
    String? aiTips,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);

  Map<String, dynamic> toMap() => {
        'xid': xid,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'url': url,
        'wikipedia': wikipedia,
        'osm': osm,
        'rate': rate,
        'highlight': highlight,
        'aiTips': aiTips,
      };

  factory Destination.fromMap(Map<String, dynamic> map) => Destination(
        xid: map['xid'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        imageUrl: map['imageUrl'] as String?,
        category: map['category'] as String,
        latitude: map['latitude'] as double,
        longitude: map['longitude'] as double,
        address: map['address'] as String?,
        url: map['url'] as String?,
        wikipedia: map['wikipedia'] as String?,
        osm: map['osm'] as String?,
        rate: map['rate'] as double?,
        highlight: map['highlight'] as String?,
        aiTips: map['aiTips'] as String?,
      );
}
