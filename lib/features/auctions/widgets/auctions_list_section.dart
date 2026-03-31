import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'auction_card.dart';

class AuctionsListSection extends StatelessWidget {
  const AuctionsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<Map<String, dynamic>> auctions = [
      {
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        'name': 'ساعة رولكس صبمارينر',
        'category': 'ساعات فاخرة',
        'currentPrice': '\$12,500',
        'startPrice': '\$10,000',
        'topBidder': 'أحمد محمد',
        'topBidderAvatar': 'https://i.pravatar.cc/150?u=ahmed',
        'status': 'نشط',
        'remainingTime': '02:45:12',
        'bidsCount': 45,
      },
      {
        'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
        'name': 'ماك بوك برو M3',
        'category': 'إلكترونيات',
        'currentPrice': '\$2,200',
        'startPrice': '\$1,500',
        'topBidder': 'سارة علي',
        'topBidderAvatar': 'https://i.pravatar.cc/150?u=sara',
        'status': 'نشط',
        'remainingTime': '15:20:00',
        'bidsCount': 12,
      },
      {
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'name': 'نايك إير جوردان',
        'category': 'أحذية الرياضية',
        'currentPrice': '\$450',
        'startPrice': '\$100',
        'topBidder': 'خالد عبدالله',
        'topBidderAvatar': 'https://i.pravatar.cc/150?u=khaled',
        'status': 'قريباً',
        'remainingTime': '00:05:40',
        'bidsCount': 89,
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final auction = auctions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: AuctionCard(auction: auction),
          );
        },
        childCount: auctions.length,
      ),
    );
  }
}
