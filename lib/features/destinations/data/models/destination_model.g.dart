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
  highlight: json['highlight'] as String?,
  createdAt: (json['createdAt'] as num?)?.toInt(),
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
      'highlight': instance.highlight,
      'createdAt': instance.createdAt,
    };
