import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile(UpdateProfileRequest request);
  Future<Either<Failure, void>> changePassword(ChangePasswordRequest request);
}
