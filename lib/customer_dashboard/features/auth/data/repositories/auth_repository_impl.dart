import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService localStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.localStorage);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      // Save all user data to local storage
      await localStorage.saveToken(user.token);
      await localStorage.saveUserId(user.id);
      await localStorage.saveUserEmail(user.email);
      await localStorage.saveUserData('firstName', user.firstName);
      await localStorage.saveUserData('lastName', user.lastName);
      await localStorage.saveUserData('role', user.role);
      await localStorage.saveUserData('phone', user.phone ?? '');
      await localStorage.saveUserData('profileImage', user.profileImage ?? '');
      await localStorage.saveUserData('address', user.address ?? '');
      return Right(user);
    } on UnauthorisedException catch (e) {
      return Left(AuthFailure(e.message ?? 'Invalid email or password'));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message ?? 'Invalid input'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on DioException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'Connection error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      // Save all user data to local storage
      await localStorage.saveToken(user.token);
      await localStorage.saveUserId(user.id);
      await localStorage.saveUserEmail(user.email);
      await localStorage.saveUserData('firstName', user.firstName);
      await localStorage.saveUserData('lastName', user.lastName);
      await localStorage.saveUserData('role', user.role);
      await localStorage.saveUserData('phone', user.phone ?? '');
      await localStorage.saveUserData('profileImage', user.profileImage ?? '');
      await localStorage.saveUserData('address', user.address ?? '');
      return Right(user);
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message ?? 'Invalid input'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on DioException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'Connection error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localStorage.clearAll();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on DioException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'Connection error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final token = await localStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Right(null);
      }

      final userId = await localStorage.getUserId();
      final userEmail = await localStorage.getUserEmail();
      final firstName = await localStorage.getUserData('firstName');
      final lastName = await localStorage.getUserData('lastName');
      final role = await localStorage.getUserData('role');

      if (userId == null ||
          userEmail == null ||
          firstName == null ||
          lastName == null ||
          role == null) {
        return const Right(null);
      }

      final phone = await localStorage.getUserData('phone');
      final profileImage = await localStorage.getUserData('profileImage');

      return Right(
        User(
          id: userId,
          firstName: firstName,
          lastName: lastName,
          email: userEmail,
          role: role,
          token: token,
          phone: phone?.isEmpty ?? true ? null : phone,
          profileImage: profileImage?.isEmpty ?? true ? null : profileImage,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localStorage.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
