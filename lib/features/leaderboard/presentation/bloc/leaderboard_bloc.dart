import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  final List<Map<String, dynamic>> users;
  const LeaderboardLoaded(this.users);
  @override
  List<Object> get props => [users];
}
class LeaderboardError extends LeaderboardState {
  final String message;
  const LeaderboardError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<LoadLeaderboard>((event, emit) async {
      emit(LeaderboardLoading());
      
      // Simulate data fetching
      await Future.delayed(const Duration(milliseconds: 800));
      
      final users = [
        {'rank': 1, 'name': 'أحمد بكري', 'wins': 15, 'bids': 120, 'score': 4500},
        {'rank': 2, 'name': 'سارة محمد', 'wins': 12, 'bids': 95, 'score': 3800},
        {'rank': 3, 'name': 'محمود علي', 'wins': 10, 'bids': 110, 'score': 3200},
        {'rank': 4, 'name': 'ياسين حسن', 'wins': 8, 'bids': 60, 'score': 2500},
        {'rank': 5, 'name': 'نورا خالد', 'wins': 7, 'bids': 85, 'score': 2100},
        {'rank': 6, 'name': 'عبدالرحمن يوسف', 'wins': 6, 'bids': 50, 'score': 1800},
      ];
      
      emit(LeaderboardLoaded(users));
    });
  }
}
