import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/repository/auth_locale_repository.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final AuthRemoteRepository _authRemoteRepository = AuthRemoteRepository();
  final AuthLocaleRepository _authLocaleRepository = AuthLocaleRepository();
  final spService = SpService();

  void getUserData() async {
    try {
      emit(AuthLoading());
      final userModel = await _authRemoteRepository.getUserData();
      if (userModel != null) {
        emit(AuthSignedIn(userModel));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      throw e.toString();
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await _authRemoteRepository.signUp(
          name: name, email: email, password: password);
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
      throw e.toString();
    }
  }

  void signIn({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final user =
          await _authRemoteRepository.signIn(email: email, password: password);
      // store token
      if (user.token.isNotEmpty) {
        await spService.setToken(user.token);
      }

      await _authLocaleRepository.insertUser(user);
      emit(AuthSignedIn(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      throw e.toString();
    }
  }
}
