class LinkPreviewEntity {
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;

  const LinkPreviewEntity({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
  });

  factory LinkPreviewEntity.fromJson(Map<String, dynamic> json) {
    return LinkPreviewEntity(
      url: json['url'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'description': description,
        'image': imageUrl,
      };
}
