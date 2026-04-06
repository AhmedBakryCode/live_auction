import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/bid_model.dart';
import '../../domain/repositories/auction_repository.dart';

// Events
abstract class BidHistoryEvent extends Equatable {
  const BidHistoryEvent();
  @override
  List<Object> get props => [];
}

class LoadBidHistory extends BidHistoryEvent {
  final int auctionId;
  const LoadBidHistory(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}

// States
abstract class BidHistoryState extends Equatable {
  const BidHistoryState();
  @override
  List<Object> get props => [];
}

class BidHistoryInitial extends BidHistoryState {}

class BidHistoryLoading extends BidHistoryState {}

class BidHistoryLoaded extends BidHistoryState {
  final List<BidModel> bids;
  const BidHistoryLoaded(this.bids);
  @override
  List<Object> get props => [bids];
}

class BidHistoryError extends BidHistoryState {
  final String message;
  const BidHistoryError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class BidHistoryBloc extends Bloc<BidHistoryEvent, BidHistoryState> {
  final AuctionRepository repository;

  BidHistoryBloc({required this.repository}) : super(BidHistoryInitial()) {
    on<LoadBidHistory>(_onLoadBidHistory);
  }

  Future<void> _onLoadBidHistory(
    LoadBidHistory event,
    Emitter<BidHistoryState> emit,
  ) async {
    emit(BidHistoryLoading());

    final result = await repository.getAuctionBids(event.auctionId);

    result.fold(
      (failure) => emit(BidHistoryError(failure.message)),
      (bids) => emit(BidHistoryLoaded(bids)),
    );
  }
}
