class DestinationDto {
  const DestinationDto({
    required this.xid,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    this.highlight,
    this.createdAt,
  });

  final String xid;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final double latitude;
  final double longitude;
  final String? address;
  final String? highlight;
  final int? createdAt;

  DestinationDto copyWith({
    String? xid,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? latitude,
    double? longitude,
    String? address,
    String? highlight,
    int? createdAt,
  }) {
    return DestinationDto(
      xid: xid ?? this.xid,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      highlight: highlight ?? this.highlight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationDto &&
          runtimeType == other.runtimeType &&
          xid == other.xid &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(xid, imageUrl);

  @override
  String toString() => 'DestinationDto($xid, $name)';
}
