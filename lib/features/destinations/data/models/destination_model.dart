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
    String? highlight,
    String? aiTips,
    int? createdAt,
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
        'highlight': highlight,
        'aiTips': aiTips,
        'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      };

  factory Destination.fromMap(Map<String, dynamic> map) => Destination(
        xid: map['xid'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        imageUrl: map['imageUrl'] as String?,
        category: map['category'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        address: map['address'] as String?,
        highlight: map['highlight'] as String?,
        aiTips: map['aiTips'] as String?,
        createdAt: map['createdAt'] as int?,
      );
}
