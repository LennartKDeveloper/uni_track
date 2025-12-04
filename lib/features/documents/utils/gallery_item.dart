class GalleryItem {
  final String imagePath;
  final String title;

  GalleryItem({required this.imagePath, required this.title});

  // Helper, um eine Kopie mit neuem Titel zu erstellen
  GalleryItem copyWith({String? imagePath, String? title}) {
    return GalleryItem(
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() => {'imagePath': imagePath, 'title': title};

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(imagePath: json['imagePath'], title: json['title']);
  }
}
