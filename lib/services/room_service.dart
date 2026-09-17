import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/room.dart';
import 'api_client.dart';

class RoomService {
  RoomService._();
  static final RoomService instance = RoomService._();

  Future<Room> createRoom({
    required String token,
    required String quizId,
    String? judul,
    String? isi,
    String? status,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiClient.baseUrl}/api/create/room'),
          headers: ApiClient.headers(token: token, body: true),
          body: jsonEncode({
            'quiz_id': quizId,
            'judul': ?judul,
            'isi': ?isi,
            'status': ?status,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final data = ApiClient.decode(response);
    if (response.statusCode != 201) {
      throw ApiException(
        ApiClient.message(data),
        statusCode: response.statusCode,
      );
    }
    return Room.fromJson((data['room'] as Map).cast<String, dynamic>());
  }

  Future<Room> updateRoomStatus({
    required String token,
    required String roomId,
    required String status,
  }) async {
    final response = await http
        .put(
          Uri.parse('${ApiClient.baseUrl}/api/room/$roomId/status'),
          headers: ApiClient.headers(token: token, body: true),
          body: jsonEncode({'room_id': roomId, 'status': status}),
        )
        .timeout(const Duration(seconds: 10));
    final data = ApiClient.decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.message(data),
        statusCode: response.statusCode,
      );
    }
    return Room.fromJson((data['room'] as Map).cast<String, dynamic>());
  }
}
