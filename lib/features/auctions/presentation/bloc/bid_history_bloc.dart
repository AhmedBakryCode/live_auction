import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class BidHistoryEvent extends Equatable {
  const BidHistoryEvent();
  @override
  List<Object> get props => [];
}

class LoadBidHistory extends BidHistoryEvent {
  final String auctionId;
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
  final List<Map<String, dynamic>> bids;
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
  BidHistoryBloc() : super(BidHistoryInitial()) {
    on<LoadBidHistory>((event, emit) async {
      emit(BidHistoryLoading());
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      final bids = [
        {'bidderName': 'أحمد بكري', 'amount': 45000.0, 'time': 'منذ دقيقتين', 'isHighest': true},
        {'bidderName': 'محمد علي', 'amount': 44500.0, 'time': 'منذ 5 دقائق', 'isHighest': false},
        {'bidderName': 'خالد سليم', 'amount': 44000.0, 'time': 'منذ 12 دقيقة', 'isHighest': false},
      ];
      emit(BidHistoryLoaded(bids));
    });
  }
}
