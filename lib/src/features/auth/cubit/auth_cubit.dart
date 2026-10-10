import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/google_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  String verificationId = '';

  AuthCubit() : super(AuthInitial());

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(AuthLoading());
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'full name': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'signed time': FieldValue.serverTimestamp(),
        });
        emit(AuthLoaded());
      } else {
        emit(const AuthError(message: 'Sign up failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Sign up failed'));
    } catch (error) {
      emit(AuthError(message: 'Failed to save user details to Firestore: $error'));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        emit(AuthLoaded());
      } else {
        emit(const AuthError(message: 'Sign in failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Sign in failed'));
    } catch (error) {
      emit(AuthError(message: 'Sign in failed: $error'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await GoogleAuthService.signInWithGoogle();
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'full name': user.displayName ?? 'Google User',
            'email': user.email ?? '',
            'signed time': FieldValue.serverTimestamp(),
          });
        }
        emit(AuthLoaded());
      } else {
        emit(AuthInitial());
      }
    } catch (error) {
      emit(AuthError(message: 'Google Sign In failed: $error'));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(AuthPasswordResetSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? 'Password reset failed'));
    } catch (error) {
      emit(AuthError(message: 'Password reset failed: $error'));
    }
  }

  Future<void> checkSmsCode({
    required String smsCode,
    required String verificationId,
  }) async {
    emit(AuthLoading());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (result.user != null) {
        emit(AuthOtpSuccess());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        message: e.message ?? 'OTP verification failed',
      ));
    } catch (error) {
      emit(AuthError(message: 'OTP verification failed: $error'));
    }
  }
}

void logOut() async {
  await FirebaseAuth.instance.signOut();
}
