// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Destination _$DestinationFromJson(Map<String, dynamic> json) => _Destination(
  xid: json['xid'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  category: json['category'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String?,
  url: json['url'] as String?,
  wikipedia: json['wikipedia'] as String?,
  osm: json['osm'] as String?,
  rate: (json['rate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DestinationToJson(_Destination instance) =>
    <String, dynamic>{
      'xid': instance.xid,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'url': instance.url,
      'wikipedia': instance.wikipedia,
      'osm': instance.osm,
      'rate': instance.rate,
    };
