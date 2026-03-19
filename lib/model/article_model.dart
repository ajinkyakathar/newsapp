class Article {
  final String title;
  final String summary;

  Article({required this.title, required this.summary});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}