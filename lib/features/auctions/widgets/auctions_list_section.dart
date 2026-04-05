import 'package:flutter/material.dart';
import 'auction_card.dart';
import '../repositories/auctions_repository.dart';
import '../models/auction_model.dart';
import '../../../core/theme/app_colors.dart';

class AuctionsListSection extends StatefulWidget {
  const AuctionsListSection({super.key});

  @override
  State<AuctionsListSection> createState() => _AuctionsListSectionState();
}

class _AuctionsListSectionState extends State<AuctionsListSection> {
  final AuctionsRepository _repository = AuctionsRepository();
  late Future<List<AuctionModel>> _auctionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAuctions();
  }

  void _fetchAuctions() {
    setState(() {
      _auctionsFuture = _repository.fetchAuctions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<List<AuctionModel>>(
        future: _auctionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                    const SizedBox(height: 12),
                    const Text('حدث خطأ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchAuctions,
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      label: const Text('إعادة المحاولة', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final auctions = snapshot.data ?? [];

          if (auctions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('لا توجد مزادات حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auctions.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AuctionCard(
                  auction: auctions[index],
                  onDeleteSuccess: _fetchAuctions,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
