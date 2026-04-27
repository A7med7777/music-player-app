import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';

enum AuthState { anonymous, signedIn, signedOut }

abstract class AuthRepository {
  Stream<AuthState> get state;
  String? get currentUid;
  Future<Either<Failure, void>> signInAnonymously();
  Future<Either<Failure, void>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
}
