import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';
import '../network/network_exceptions.dart';
import '../network/result.dart';
import '../storage/local_storage_service.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<AppUser>> signIn({required String email, required String password});

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return AppUser(
      email: user.email ?? '',
      fullName: user.displayName ?? (user.email?.split('@').first ?? 'User'),
      joinedAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(fullName);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Result.success(
        AppUser(email: user.email ?? email, fullName: fullName, joinedAt: DateTime.now()),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(ValidationFailure(e.message ?? 'Sign up failed'));
    } catch (e) {
      return Result.failure(ValidationFailure('Sign up failed: $e'));
    }
  }

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      return Result.success(
        AppUser(
          email: user.email ?? email,
          fullName: user.displayName ?? (user.email?.split('@').first ?? 'User'),
          joinedAt: user.metadata.creationTime ?? DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(ValidationFailure(e.message ?? 'Sign in failed'));
    } catch (e) {
      return Result.failure(ValidationFailure('Sign in failed: $e'));
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;

  @override
  AppUser? get currentUser => _storage.getCurrentUser();

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = _storage.findAccount(normalizedEmail);
    if (existing != null) {
      return const Result.failure(
        ValidationFailure('An account with this email already exists.'),
      );
    }

    await _storage.saveAccount(
      email: normalizedEmail,
      passwordHash: _hash(password),
      fullName: fullName.trim(),
    );
    await _storage.setSession(normalizedEmail);

    return Result.success(
      AppUser(email: normalizedEmail, fullName: fullName.trim(), joinedAt: DateTime.now()),
    );
  }

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _storage.findAccount(normalizedEmail);

    if (account == null || account['passwordHash'] != _hash(password)) {
      return const Result.failure(ValidationFailure('Incorrect email or password.'));
    }

    await _storage.setSession(normalizedEmail);
    return Result.success(
      AppUser(
        email: normalizedEmail,
        fullName: account['fullName'] as String,
        joinedAt: DateTime.tryParse(account['joinedAt'] as String? ?? '') ?? DateTime.now(),
      ),
    );
  }

  @override
  Future<void> signOut() => _storage.clearSessionData();

  String _hash(String password) => sha256.convert(utf8.encode(password)).toString();
}
