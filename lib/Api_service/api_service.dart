import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/article_model.dart';

class ApiService {
  Future<List<Article>> fetchArticles() async {
    final response = await http.get(
      Uri.parse('https://api.spaceflightnewsapi.net/v4/articles/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data['results'];

      return articles.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}