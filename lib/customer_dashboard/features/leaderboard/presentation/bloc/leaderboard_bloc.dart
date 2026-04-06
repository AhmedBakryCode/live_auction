import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();
  @override
  List<Object> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {}

// States
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();
  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final LeaderboardData data;
  const LeaderboardLoaded(this.data);
  @override
  List<Object> get props => [data];
}

class LeaderboardError extends LeaderboardState {
  final String message;
  const LeaderboardError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository repository;

  LeaderboardBloc(this.repository) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());

    final result = await repository.getLeaderboard();

    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (data) => emit(LeaderboardLoaded(data)),
    );
  }
}
