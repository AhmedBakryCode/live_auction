import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auction.dart';

// Events
abstract class AuctionEvent extends Equatable {
  const AuctionEvent();
  @override
  List<Object> get props => [];
}

class LoadAuctions extends AuctionEvent {}

// States
abstract class AuctionState extends Equatable {
  const AuctionState();
  @override
  List<Object> get props => [];
}

class AuctionInitial extends AuctionState {}
class AuctionLoading extends AuctionState {}
class AuctionLoaded extends AuctionState {
  final List<Auction> auctions;
  const AuctionLoaded(this.auctions);
  @override
  List<Object> get props => [auctions];
}
class AuctionError extends AuctionState {
  final String message;
  const AuctionError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class AuctionBloc extends Bloc<AuctionEvent, AuctionState> {
  AuctionBloc() : super(AuctionInitial()) {
    on<LoadAuctions>((event, emit) async {
      emit(AuctionLoading());
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      final auctions = [
        Auction(
          id: '1',
          title: 'ساعة رولكس كوزموغراف دايتونا',
          description: 'ساعة رولكس أصلية بحالة ممتازة مع العلبة والأوراق.',
          currentBid: 45000.0,
          endTime: DateTime.now().add(const Duration(hours: 2)),
          imageUrl: 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?auto=format&fit=crop&q=80&w=400',
          totalBids: 15,
          sellerName: 'أحمد محمود',
        ),
        Auction(
          id: '2',
          title: 'سيارة مرسيدس G-Class 2023',
          description: 'سيارة مرسيدس كسر زيرو، كاملة المواصفات.',
          currentBid: 250000.0,
          endTime: DateTime.now().add(const Duration(hours: 5)),
          imageUrl: 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&q=80&w=400',
          totalBids: 8,
          sellerName: 'معرض النخبة',
        ),
        Auction(
          id: '3',
          title: 'آيفون 15 برو ماكس 512 جيجا',
          description: 'هاتف جديد تماماً بتغليف المصنع.',
          currentBid: 55000.0,
          endTime: DateTime.now().add(const Duration(hours: 1)),
          imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?auto=format&fit=crop&q=80&w=400',
          totalBids: 24,
          sellerName: 'متجر التكنولوجيا',
        ),
        Auction(
          id: '4',
          title: 'لوحة فنية نادرة - القرن الـ 19',
          description: 'لوحة زيتية أصلية لمبدع مجهول، موثقة.',
          currentBid: 12000.0,
          endTime: DateTime.now().add(const Duration(hours: 10)),
          imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?auto=format&fit=crop&q=80&w=400',
          totalBids: 5,
          sellerName: 'قاعة الفنون',
        ),
      ];
      
      emit(AuctionLoaded(auctions));
    });
  }
}
