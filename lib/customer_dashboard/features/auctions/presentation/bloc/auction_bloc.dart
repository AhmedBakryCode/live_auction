import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/bid_model.dart';
import '../../domain/entities/auction.dart';
import '../../domain/repositories/auction_repository.dart';

// Events
abstract class AuctionEvent extends Equatable {
  const AuctionEvent();
  @override
  List<Object> get props => [];
}

class LoadActiveAuctions extends AuctionEvent {}

class LoadUpcomingAuctions extends AuctionEvent {}

class LoadClosedAuctions extends AuctionEvent {}

class LoadRepostedAuctions extends AuctionEvent {}

class LoadPaidAuctions extends AuctionEvent {}

class JoinAuction extends AuctionEvent {
  final int auctionId;
  const JoinAuction(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}

class PlaceBid extends AuctionEvent {
  final int auctionId;
  final double amount;
  const PlaceBid({required this.auctionId, required this.amount});
  @override
  List<Object> get props => [auctionId, amount];
}

class LoadAuctionBids extends AuctionEvent {
  final int auctionId;
  const LoadAuctionBids(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}

// States
abstract class AuctionState extends Equatable {
  const AuctionState();
  @override
  List<Object> get props => [];
}

class AuctionInitial extends AuctionState {}

class AuctionLoading extends AuctionState {}

class AuctionsLoaded extends AuctionState {
  final List<Auction> activeAuctions;
  final List<Auction> upcomingAuctions;
  final List<Auction> closedAuctions;
  final List<Auction> repostedAuctions;
  final List<Auction> paidAuctions;

  const AuctionsLoaded({
    this.activeAuctions = const [],
    this.upcomingAuctions = const [],
    this.closedAuctions = const [],
    this.repostedAuctions = const [],
    this.paidAuctions = const [],
  });

  AuctionsLoaded copyWith({
    List<Auction>? activeAuctions,
    List<Auction>? upcomingAuctions,
    List<Auction>? closedAuctions,
    List<Auction>? repostedAuctions,
    List<Auction>? paidAuctions,
  }) {
    return AuctionsLoaded(
      activeAuctions: activeAuctions ?? this.activeAuctions,
      upcomingAuctions: upcomingAuctions ?? this.upcomingAuctions,
      closedAuctions: closedAuctions ?? this.closedAuctions,
      repostedAuctions: repostedAuctions ?? this.repostedAuctions,
      paidAuctions: paidAuctions ?? this.paidAuctions,
    );
  }

  @override
  List<Object> get props => [
    activeAuctions,
    upcomingAuctions,
    closedAuctions,
    repostedAuctions,
    paidAuctions,
  ];
}

class AuctionError extends AuctionState {
  final String message;
  const AuctionError(this.message);
  @override
  List<Object> get props => [message];
}

class JoinAuctionLoading extends AuctionState {}

class JoinAuctionSuccess extends AuctionState {
  final int auctionId;
  const JoinAuctionSuccess(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}

class JoinAuctionError extends AuctionState {
  final String message;
  const JoinAuctionError(this.message);
  @override
  List<Object> get props => [message];
}

class PlaceBidLoading extends AuctionState {}

class PlaceBidSuccess extends AuctionState {
  final int auctionId;
  final double amount;
  const PlaceBidSuccess({required this.auctionId, required this.amount});
  @override
  List<Object> get props => [auctionId, amount];
}

class PlaceBidError extends AuctionState {
  final String message;
  const PlaceBidError(this.message);
  @override
  List<Object> get props => [message];
}

class AuctionBidsLoading extends AuctionState {}

class AuctionBidsLoaded extends AuctionState {
  final List<BidModel> bids;
  const AuctionBidsLoaded(this.bids);
  @override
  List<Object> get props => [bids];
}

class AuctionBidsError extends AuctionState {
  final String message;
  const AuctionBidsError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class AuctionBloc extends Bloc<AuctionEvent, AuctionState> {
  final AuctionRepository repository;

  AuctionBloc({required this.repository}) : super(AuctionInitial()) {
    on<LoadActiveAuctions>(_onLoadActiveAuctions);
    on<LoadUpcomingAuctions>(_onLoadUpcomingAuctions);
    on<LoadClosedAuctions>(_onLoadClosedAuctions);
    on<LoadRepostedAuctions>(_onLoadRepostedAuctions);
    on<LoadPaidAuctions>(_onLoadPaidAuctions);
    on<JoinAuction>(_onJoinAuction);
    on<PlaceBid>(_onPlaceBid);
    on<LoadAuctionBids>(_onLoadAuctionBids);
  }

  Future<void> _onLoadActiveAuctions(
    LoadActiveAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    emit(AuctionLoading());
    final result = await repository.getActiveAuctions();
    result.fold(
      (failure) => emit(AuctionError(failure.message)),
      (auctions) => emit(AuctionsLoaded(activeAuctions: auctions)),
    );
  }

  Future<void> _onLoadUpcomingAuctions(
    LoadUpcomingAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    // Don't emit loading to avoid UI flicker, just update data
    final result = await repository.getUpcomingAuctions();
    result.fold(
      (failure) {
        // Silently fail for secondary loads, don't break the UI
      },
      (auctions) {
        if (state is AuctionsLoaded) {
          emit((state as AuctionsLoaded).copyWith(upcomingAuctions: auctions));
        } else {
          emit(AuctionsLoaded(upcomingAuctions: auctions));
        }
      },
    );
  }

  Future<void> _onLoadClosedAuctions(
    LoadClosedAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    // Don't emit loading to avoid UI flicker, just update data
    final result = await repository.getClosedAuctions();
    result.fold(
      (failure) {
        // Silently fail for secondary loads
      },
      (auctions) {
        if (state is AuctionsLoaded) {
          emit((state as AuctionsLoaded).copyWith(closedAuctions: auctions));
        } else {
          emit(AuctionsLoaded(closedAuctions: auctions));
        }
      },
    );
  }

  Future<void> _onLoadRepostedAuctions(
    LoadRepostedAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    // Don't emit loading to avoid UI flicker, just update data
    final result = await repository.getRepostedAuctions();
    result.fold((failure) {}, (auctions) {
      if (state is AuctionsLoaded) {
        emit((state as AuctionsLoaded).copyWith(repostedAuctions: auctions));
      } else {
        emit(AuctionsLoaded(repostedAuctions: auctions));
      }
    });
  }

  Future<void> _onLoadPaidAuctions(
    LoadPaidAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    // Don't emit loading to avoid UI flicker, just update data
    final result = await repository.getPaidAuctions();
    result.fold((failure) {}, (auctions) {
      if (state is AuctionsLoaded) {
        emit((state as AuctionsLoaded).copyWith(paidAuctions: auctions));
      } else {
        emit(AuctionsLoaded(paidAuctions: auctions));
      }
    });
  }

  Future<void> _onJoinAuction(
    JoinAuction event,
    Emitter<AuctionState> emit,
  ) async {
    emit(JoinAuctionLoading());
    final result = await repository.joinAuction(event.auctionId);
    result.fold(
      (failure) => emit(JoinAuctionError(failure.message)),
      (_) => emit(JoinAuctionSuccess(event.auctionId)),
    );
  }

  Future<void> _onPlaceBid(PlaceBid event, Emitter<AuctionState> emit) async {
    emit(PlaceBidLoading());
    final result = await repository.placeBid(event.auctionId, event.amount);
    result.fold(
      (failure) => emit(PlaceBidError(failure.message)),
      (_) => emit(
        PlaceBidSuccess(auctionId: event.auctionId, amount: event.amount),
      ),
    );
  }

  Future<void> _onLoadAuctionBids(
    LoadAuctionBids event,
    Emitter<AuctionState> emit,
  ) async {
    debugPrint('🔵 Loading bids for auction ${event.auctionId}');
    emit(AuctionBidsLoading());
    final result = await repository.getAuctionBids(event.auctionId);
    result.fold(
      (failure) {
        debugPrint('🔴 Error loading bids: ${failure.message}');
        emit(AuctionBidsError(failure.message));
      },
      (bids) {
        debugPrint('🟢 Loaded ${bids.length} bids');
        for (var bid in bids) {
          debugPrint('   Bid: ${bid.amount} by ${bid.user.fullName}');
        }
        emit(AuctionBidsLoaded(bids));
      },
    );
  }
}
