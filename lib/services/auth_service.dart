import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

class AuthService extends ChangeNotifier {
  oauth2.Client? _client;
  bool get isAuthenticated => _client != null;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  String get clientId => dotenv.env['TICKTICK_CLIENT_ID'] ?? '';
  String get clientSecret => dotenv.env['TICKTICK_CLIENT_SECRET'] ?? '';
  String get redirectUri => dotenv.env['TICKTICK_REDIRECT_URI'] ?? '';
  String get apiBaseUrl => dotenv.env['TICKTICK_API_BASE_URL'] ?? 'https://api.ticktick.com/api/v2';
  
  oauth2.Client? get client => _client;

  Future<void> init() async {
    final savedCredentials = await _secureStorage.read(key: 'ticktick_credentials');
    if (savedCredentials != null) {
      try {
        final credentials = oauth2.Credentials.fromJson(savedCredentials);
        _client = oauth2.Client(credentials, identifier: clientId, secret: clientSecret);
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<bool> authorize() async {
    final authUrl = Uri.parse('https://ticktick.com/oauth/authorize')
        .replace(queryParameters: {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': 'tasks:read tasks:write',
    });

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleAuthCode(String code) async {
    try {
      final tokenEndpoint = Uri.parse('https://ticktick.com/oauth/token');
      final response = await http.post(
        tokenEndpoint,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final credentials = oauth2.Credentials(
          data['access_token'],
          refreshToken: data['refresh_token'],
          expiration: DateTime.now().add(Duration(seconds: data['expires_in'])),
          tokenEndpoint: tokenEndpoint,
          scopes: ['tasks:read', 'tasks:write'],
        );

        _client = oauth2.Client(credentials, identifier: clientId, secret: clientSecret);
        await _secureStorage.write(
          key: 'ticktick_credentials',
          value: credentials.toJson(),
        );
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _client?.close();
    _client = null;
    await _secureStorage.delete(key: 'ticktick_credentials');
    notifyListeners();
  }
} 