import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final AuthRemoteRepository _authRemoteRepository = AuthRemoteRepository();

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
      emit(AuthSignedIn(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      throw e.toString();
    }
  }
}
