/// Destination data returned by Gemini (excludes image — resolved via Wikidata).
class GeminiDestinationApiModel {
  const GeminiDestinationApiModel({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.highlight,
    required this.address,
  });

  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final String highlight;
  final String address;

  @override
  String toString() => 'GeminiDestinationApiModel($name)';
}
