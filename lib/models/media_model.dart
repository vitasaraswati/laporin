enum MediaType { image, video }

class MediaFile {
  final String id;
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final DateTime uploadedAt;

  MediaFile({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    required this.uploadedAt,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] as String,
      url: json['url'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.image,
      ),
      thumbnailUrl: json['thumbnail_url'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type.name,
      'thumbnail_url': thumbnailUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
