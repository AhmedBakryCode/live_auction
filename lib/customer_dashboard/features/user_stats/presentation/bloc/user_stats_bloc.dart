import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/user_stats_repository.dart';

// Events
abstract class UserStatsEvent extends Equatable {
  const UserStatsEvent();
  @override
  List<Object> get props => [];
}

class LoadUserStats extends UserStatsEvent {}

// States
abstract class UserStatsState extends Equatable {
  const UserStatsState();
  @override
  List<Object> get props => [];
}

class UserStatsInitial extends UserStatsState {}
class UserStatsLoading extends UserStatsState {}
class UserStatsLoaded extends UserStatsState {
  final UserStats stats;
  const UserStatsLoaded(this.stats);
  @override
  List<Object> get props => [stats];
}
class UserStatsError extends UserStatsState {
  final String message;
  const UserStatsError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class UserStatsBloc extends Bloc<UserStatsEvent, UserStatsState> {
  final UserStatsRepository repository;

  UserStatsBloc(this.repository) : super(UserStatsInitial()) {
    on<LoadUserStats>(_onLoadUserStats);
  }

  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<UserStatsState> emit,
  ) async {
    emit(UserStatsLoading());

    final result = await repository.getUserStats();

    result.fold(
      (failure) => emit(UserStatsError(failure.message)),
      (stats) => emit(UserStatsLoaded(stats)),
    );
  }
}
