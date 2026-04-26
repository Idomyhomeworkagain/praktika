import 'dart:convert';
import 'package:http/http.dart' as http;

class ChessApi {
  static const String baseUrl = 'http://localhost:8000';

  // Профиль - это один объект (Map)
  Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/profile?user_id=$userId'),
    );
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // Прогресс - это тоже один объект (Map), внутри которого список ID
  Future<Map<String, dynamic>> getProgress(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/progress/path?user_id=$userId'),
    );
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // Задачи - это СПИСОК объектов (List)
  Future<List<dynamic>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tasks'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    }
    throw Exception('Ошибка загрузки задач');
  }

  Future<Map<String, dynamic>> getBotMove(String fen, int level) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/engine/move'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fen': fen, 'bot_level': level}),
    );
    return json.decode(response.body);
  }

  Future<void> completeLevel(int userId, int levelId, int stars) async {
    await http.post(
      Uri.parse('$baseUrl/api/level/complete'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'level_id': levelId,
        'stars': stars,
      }),
    );
  }
}
