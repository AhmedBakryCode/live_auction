import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

// Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object> get props => [];
}

class LoadWallet extends WalletEvent {}

class Deposit extends WalletEvent {
  final double amount;
  final String paymentMethod;
  const Deposit({required this.amount, required this.paymentMethod});
  @override
  List<Object> get props => [amount, paymentMethod];
}

// States
abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;
  const WalletLoaded({required this.wallet, required this.transactions});
  @override
  List<Object> get props => [wallet, transactions];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object> get props => [message];
}

class DepositLoading extends WalletState {}

class DepositSuccess extends WalletState {
  final DepositResponse depositResponse;
  final String paymentMethod;
  const DepositSuccess(this.depositResponse, this.paymentMethod);
  @override
  List<Object> get props => [depositResponse, paymentMethod];
}

class DepositError extends WalletState {
  final String message;
  const DepositError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc(this.repository) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<Deposit>(_onDeposit);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final walletResult = await repository.getWallet();
    final transactionsResult = await repository.getTransactions();

    walletResult.fold((failure) => emit(WalletError(failure.message)), (
      wallet,
    ) {
      transactionsResult.fold(
        (failure) => emit(WalletError(failure.message)),
        (transactions) =>
            emit(WalletLoaded(wallet: wallet, transactions: transactions)),
      );
    });
  }

  Future<void> _onDeposit(Deposit event, Emitter<WalletState> emit) async {
    emit(DepositLoading());

    final result = await repository.deposit(
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) => emit(DepositError(failure.message)),
      (depositResponse) =>
          emit(DepositSuccess(depositResponse, event.paymentMethod)),
    );
  }
}
