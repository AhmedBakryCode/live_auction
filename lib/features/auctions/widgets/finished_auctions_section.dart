import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_header.dart';
import '../models/auction_model.dart';
import '../repositories/auctions_repository.dart';
import 'package:intl/intl.dart';
import '../screens/auction_details_screen.dart';

class FinishedAuctionsSection extends StatefulWidget {
  const FinishedAuctionsSection({super.key});

  @override
  State<FinishedAuctionsSection> createState() => _FinishedAuctionsSectionState();
}

class _FinishedAuctionsSectionState extends State<FinishedAuctionsSection> {
  final AuctionsRepository _repository = AuctionsRepository();
  late Future<List<AuctionModel>> _finishedAuctionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchFinishedAuctions();
  }

  void _fetchFinishedAuctions() {
    setState(() {
      _finishedAuctionsFuture = _repository.fetchAuctions().then((auctions) {
        final now = DateTime.now();
        return auctions.where((a) {
          try {
            return DateTime.parse(a.endTime).isBefore(now);
          } catch (_) {
            return false;
          }
        }).toList();
      });
    });
  }

  String _getTimeAgo(String endTimeStr) {
    try {
      final end = DateTime.parse(endTimeStr);
      final diff = DateTime.now().difference(end);
      if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
      if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
      if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
      return 'الآن';
    } catch (_) {
      return endTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(title: 'مزادات انتهت مؤخراً'),
        ),
        SizedBox(
          height: 180,
          child: FutureBuilder<List<AuctionModel>>(
            future: _finishedAuctionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'حدث خطأ أثناء جلب المزادات المنتهية',
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                );
              }

              final finished = snapshot.data ?? [];
              if (finished.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد مزادات منتهية مؤخراً',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: finished.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = finished[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuctionDetailsScreen(id: item.id)),
                      );
                    },
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: item.imageUrl != null
                                ? Image.network(
                                    item.imageUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, _, __) => Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('\$${(item.currentPrice ?? item.startPrice).toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                      Text(_getTimeAgo(item.endTime), style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
