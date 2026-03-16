import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class BiddingEvent extends Equatable {
  const BiddingEvent();
  @override
  List<Object> get props => [];
}

class PlaceBid extends BiddingEvent {
  final double amount;
  const PlaceBid(this.amount);
  @override
  List<Object> get props => [amount];
}

// States
abstract class BiddingState extends Equatable {
  const BiddingState();
  @override
  List<Object> get props => [];
}

class BiddingInitial extends BiddingState {}
class BiddingLoading extends BiddingState {}
class BiddingSuccess extends BiddingState {
  final double newBid;
  const BiddingSuccess(this.newBid);
  @override
  List<Object> get props => [newBid];
}
class BiddingError extends BiddingState {
  final String message;
  const BiddingError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class BiddingBloc extends Bloc<BiddingEvent, BiddingState> {
  BiddingBloc() : super(BiddingInitial()) {
    on<PlaceBid>((event, emit) async {
      emit(BiddingLoading());
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      emit(BiddingSuccess(event.amount));
    });
  }
}
