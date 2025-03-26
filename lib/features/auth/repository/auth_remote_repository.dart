import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/repository/auth_locale_repository.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final spServide = SpService();
  final authLocalRepository = AuthLocaleRepository();

  Future<UserModel> signUp(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {'name': name, 'email': email, 'password': password},
        ),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['msg'];
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {'email': email, 'password': password},
        ),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'];
      }
      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await spServide.getToken();
      if (token == null) {
        return null;
      }
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/tokenIsValid'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userResponse =
          await http.get(Uri.parse('${Constants.backendUri}/auth'), headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });
      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['msg'];
      }

      return UserModel.fromJson(userResponse.body);
    } catch (_) {
      final user = authLocalRepository.getUser();
      return user;
    }
  }
}
