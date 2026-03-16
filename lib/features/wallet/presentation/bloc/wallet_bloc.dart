import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object> get props => [];
}

class LoadWallet extends WalletEvent {}

// States
abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}
class WalletLoading extends WalletState {}
class WalletLoaded extends WalletState {
  final double balance;
  final List<Map<String, dynamic>> transactions;
  const WalletLoaded({required this.balance, required this.transactions});
  @override
  List<Object> get props => [balance, transactions];
}
class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<LoadWallet>((event, emit) async {
      emit(WalletLoading());
      // Simulate data fetching
      await Future.delayed(const Duration(seconds: 1));
      emit(const WalletLoaded(
        balance: 2450.75,
        transactions: [
          {'title': 'مزايدة جديدة', 'amount': -250.0, 'date': 'اليوم، 2:30 م', 'type': 'Bid'},
          {'title': 'إيداع عبر البطاقة', 'amount': 1000.0, 'date': 'أمس، 10:15 ص', 'type': 'Deposit'},
        ],
      ));
    });
  }
}
