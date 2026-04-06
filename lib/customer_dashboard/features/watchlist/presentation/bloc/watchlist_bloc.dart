import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auctions/domain/entities/auction.dart';
import '../../domain/repositories/watchlist_repository.dart';

// Events
abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();
  @override
  List<Object> get props => [];
}

class LoadWatchlist extends WatchlistEvent {}

// States
abstract class WatchlistState extends Equatable {
  const WatchlistState();
  @override
  List<Object> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<Auction> auctions;
  const WatchlistLoaded(this.auctions);
  @override
  List<Object> get props => [auctions];
}

class WatchlistError extends WatchlistState {
  final String message;
  const WatchlistError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository repository;

  WatchlistBloc({required this.repository}) : super(WatchlistInitial()) {
    on<LoadWatchlist>((event, emit) async {
      emit(WatchlistLoading());

      final result = await repository.getUserParticipatedAuctions();

      result.fold(
        (failure) => emit(WatchlistError(failure.message)),
        (auctions) => emit(WatchlistLoaded(auctions)),
      );
    });
  }
}
