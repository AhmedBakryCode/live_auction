import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auctions/domain/entities/auction.dart';

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
  final List<Auction> items;
  const WatchlistLoaded(this.items);
  @override
  List<Object> get props => [items];
}
class WatchlistError extends WatchlistState {
  final String message;
  const WatchlistError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc() : super(WatchlistInitial()) {
    on<LoadWatchlist>((event, emit) async {
      emit(WatchlistLoading());
      
      // Simulate data fetching
      await Future.delayed(const Duration(milliseconds: 800));
      
      final items = [
        Auction(
          id: '1',
          title: 'ساعة رولكس كوزموغراف دايتونا',
          description: 'ساعة رولكس أصلية بحالة ممتازة مع العلبة والأوراق.',
          currentBid: 45000.0,
          endTime: DateTime.now().add(const Duration(hours: 2)),
          imageUrl: 'https://images.unsplash.com/photo-1524333892444-246e63bb9112?auto=format&fit=crop&q=80&w=300',
          totalBids: 15,
          sellerName: 'أحمد محمود',
        ),
        Auction(
          id: '3',
          title: 'طقم ألماس فاخر لازورد',
          description: 'طقم ألماس مكون من قلادة وأقراط، عيار 18.',
          currentBid: 12000.0,
          endTime: DateTime.now().add(const Duration(minutes: 45)),
          imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb0ce33e?auto=format&fit=crop&q=80&w=300',
          totalBids: 24,
          sellerName: 'مجوهرات النور',
        ),
      ];
      
      emit(WatchlistLoaded(items));
    });
  }
}
