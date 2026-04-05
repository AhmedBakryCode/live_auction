import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auctions/repositories/auctions_repository.dart';
import '../../auctions/models/auction_model.dart';
class AuctionsManagementTable extends StatefulWidget {
  const AuctionsManagementTable({super.key});

  @override
  State<AuctionsManagementTable> createState() =>
      _AuctionsManagementTableState();
}

class _AuctionsManagementTableState extends State<AuctionsManagementTable> {
  final AuctionsRepository _repository = AuctionsRepository();
  late Future<List<AuctionModel>> _auctionsFuture;
  final Set<int> _deletingIds = {};

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

  // Calculate remaining time from end_time
  String _getRemainingTime(String endTimeStr) {
    try {
      final endTime = DateTime.parse(endTimeStr);
      final now = DateTime.now();
      if (endTime.isBefore(now)) return 'منتهي';

      final diff = endTime.difference(now);
      if (diff.inDays > 0)
        return '${diff.inDays} يوم ${diff.inHours % 24} ساعة';
      return '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}';
    } catch (_) {
      return endTimeStr;
    }
  }

  Future<void> _handleDelete(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف هذا المزاد؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'حذف',
              style: TextStyle(
                color: AppColors.error,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _deletingIds.add(id);
    });

    try {
      final msg = await _repository.deleteAuction(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg ?? 'تم الحذف بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchAuctions(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _handleDelete(context, id),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deletingIds.remove(id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'إدارة المزادات',
            onActionPressed: () {},
            actionText: 'عرض الكل',
          ),

          FutureBuilder<List<AuctionModel>>(
            future: _auctionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchAuctions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(color: Colors.black),
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
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'لا توجد مزادات متاحة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return AppTable(
                headers: const [
                  'المنتج',
                  'السعر المبدئي',
                  'أعلى مزايد (ID)',
                  'الحالة',
                  'الوقت المتبقي',
                  'الإجراءات',
                ],
                rows: auctions.map((a) {
                  final bool isDeleting = _deletingIds.contains(a.id);

                  return [
                    Text(
                      a.title,
                      style: AppTextStyles.body1Bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '\$${a.startPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.body1,
                    ),
                    Text(
                      a.highestBidderId != null ? '#${a.highestBidderId}' : '-',
                      style: AppTextStyles.body1,
                    ),
                    AppBadge(
                      text: a.status == 'active'
                          ? 'نشط'
                          : (a.status == 'pending' ? 'جاري التحضير' : a.status),
                      color: a.status == 'active'
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    Text(
                      _getRemainingTime(a.endTime),
                      style: AppTextStyles.body2,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDeleting)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () => _handleDelete(context, a.id),
                            tooltip: 'حذف',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                      ],
                    ),
                  ];
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
