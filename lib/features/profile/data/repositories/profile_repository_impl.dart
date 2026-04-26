import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';
import 'package:music_player_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._datasource);
  final ProfileDatasource _datasource;

  @override
  Stream<Either<Failure, UserProfile>> watchProfile() =>
      _datasource
          .watchProfile()
          .map<Either<Failure, UserProfile>>((m) => Right(m.toDomain()))
          .handleError((_) => const Left(NetworkFailure()));

  @override
  Future<Either<Failure, void>> updateDisplayName(String name) async {
    try {
      await _datasource.updateDisplayName(name);
      return const Right(null);
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAvatar(String avatarUrl) async {
    try {
      await _datasource.updateAvatar(avatarUrl);
      return const Right(null);
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Stream<Either<Failure, ProfileSummary>> watchSummary() =>
      _datasource
          .watchSummary()
          .map<Either<Failure, ProfileSummary>>(Right.new)
          .handleError((_) => const Left(NetworkFailure()));
}
