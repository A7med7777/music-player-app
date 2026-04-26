import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/data/datasources/firebase_auth_datasource.dart';
import 'package:music_player_app/features/profile/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);
  final FirebaseAuthDatasource _datasource;

  @override
  Stream<AuthState> get state => _datasource.authStateChanges.map((user) {
    if (user == null) return AuthState.signedOut;
    if (user.isAnonymous) return AuthState.anonymous;
    return AuthState.signedIn;
  });

  @override
  String? get currentUid => _datasource.currentUid;

  @override
  Future<Either<Failure, void>> signInAnonymously() async {
    try {
      await _datasource.signInAnonymously();
      return const Right(null);
    } catch (_) {
      return Left(const PermissionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle() async {
    // Google sign-in requires google_sign_in package; placeholder.
    return Left(const PermissionFailure('Google sign-in not yet configured.'));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return const Right(null);
    } catch (_) {
      return Left(const UnknownFailure());
    }
  }
}
