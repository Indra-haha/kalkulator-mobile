import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/anggota.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, {this.statusCode = 0});

  @override
  String toString() => message;
}

class LoginResult {
  final String token;
  final Map<String, dynamic> user;

  const LoginResult({required this.token, required this.user});
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Android emulator memakai 10.0.2.2 untuk mengakses localhost dari host.
  // Untuk device fisik, ganti dengan IP komputer (mis. https://192.168.1.10:8080).
  static String get baseUrl {
    if (kIsWeb) return 'https://deera-server.my.id';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://deera-server.my.id';
    }
    return 'https://deera-server.my.id';
  }

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<LoginResult> login({
    required String nim,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/login'),
          headers: _headers(),
          body: jsonEncode({'nim': nim, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    final data = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(_message(data), statusCode: response.statusCode);
    }
    return LoginResult(
      token: data['token'] as String,
      user: (data['user'] as Map).cast<String, dynamic>(),
    );
  }

  Future<void> register({
    required String nama,
    required String nim,
    required String kelas,
    required String tanggalLahir,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/register'),
          headers: _headers(),
          body: jsonEncode({
            'nama': nama,
            'nim': nim,
            'kelas': kelas,
            'tanggal_lahir': tanggalLahir,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final data = _decode(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(_message(data), statusCode: response.statusCode);
    }


  }

  Future<void> logout(String token) async {
    final response = await http
        .post(Uri.parse('$baseUrl/api/logout'), headers: _headers(token: token))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw ApiException(
        _message(_decode(response)),
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> checkSession(String token) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/session'), headers: _headers(token: token))
        .timeout(const Duration(seconds: 10));
    final data = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(_message(data), statusCode: response.statusCode);
    }
    return (data['user'] as Map).cast<String, dynamic>();
  }

  Future<List<Anggota>> getAnggota(String token) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/anggota'), headers: _headers(token: token))
        .timeout(const Duration(seconds: 10));
    final data = _decode(response);
    if (response.statusCode != 200) {
      throw ApiException(_message(data), statusCode: response.statusCode);
    }
    final list = data['anggota'] as List;
    return list
        .map((e) => Anggota.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _message(dynamic data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Terjadi kesalahan';
  }
}
