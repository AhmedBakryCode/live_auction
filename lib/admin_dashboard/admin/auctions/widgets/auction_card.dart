import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/auction_model.dart';
import '../screens/auction_details_screen.dart';
import '../repositories/auctions_repository.dart';
import 'package:intl/intl.dart';

class AuctionCard extends StatefulWidget {
  final AuctionModel auction;
  final VoidCallback? onDeleteSuccess;

  const AuctionCard({super.key, required this.auction, this.onDeleteSuccess});

  @override
  State<AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<AuctionCard> {
  bool _isDeleting = false;
  final AuctionsRepository _repository = AuctionsRepository();

  // Calculate remaining time from end_time
  String _getRemainingTime(String endTimeStr) {
    try {
      final endTime = DateTime.parse(endTimeStr);
      final now = DateTime.now();
      if (endTime.isBefore(now)) return 'منتهي';
      
      final diff = endTime.difference(now);
      if (diff.inDays > 0) return '${diff.inDays} يوم ${diff.inHours % 24} ساعة';
      return '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
    } catch (_) {
      return endTimeStr; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AuctionDetailsScreen(id: auction.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: auction.imageUrl != null
                        ? Image.network(
                            auction.imageUrl!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, e, _) => Container(
                              width: 90, height: 90, color: Colors.grey[800],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 90, 
                            height: 90, 
                            color: Colors.grey[800],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'مزاد عام', // Fallback for category
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                              ),
                            ),
                            _buildStatusBadge(_getRemainingTime(auction.endTime) == 'منتهي' ? 'منتهي' : 'نشط'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(auction.title, style: AppTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (auction.description != null && auction.description!.isNotEmpty)
                          Text(auction.description!, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.orangeAccent),
                            const SizedBox(width: 4),
                            Text(_getRemainingTime(auction.endTime), style: AppTextStyles.caption.copyWith(color: Colors.orangeAccent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // Price Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceCol('بداية المزاد', '\$${auction.startPrice.toStringAsFixed(2)}'),
                  _buildPriceCol('السعر الحالي', '\$${(auction.currentPrice ?? auction.startPrice).toStringAsFixed(2)}', isHighlight: true),
                  _buildTimestampCol('تاريخ البدء', auction.startTime),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // Actions Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildActionButton(Icons.visibility_outlined, 'عرض', Colors.blueAccent, onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuctionDetailsScreen(id: auction.id)),
                      );
                  }),
                  const Spacer(),
                  _buildActionButton(
                    Icons.delete_outline,
                    'حذف',
                    AppColors.error,
                    isLoading: _isDeleting,
                    onTap: _isDeleting ? null : () => _handleDelete(context, auction.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status == 'نشط';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: isActive ? Colors.green : Colors.red),
          const SizedBox(width: 4),
          Text(status, style: AppTextStyles.caption.copyWith(color: isActive ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildPriceCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(value, style: isHighlight ? AppTextStyles.body1Bold.copyWith(color: AppColors.primary) : AppTextStyles.body1Bold),
      ],
    );
  }

  Widget _buildTimestampCol(String label, String value) {
    String formatted = value;
    try {
      final dt = DateTime.parse(value);
      formatted = DateFormat('yyyy/MM/dd HH:mm').format(dt);
    } catch (_) {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(formatted, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, {VoidCallback? onTap, bool isLoading = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: 20, color: onTap == null ? Colors.grey : color),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9, color: onTap == null ? Colors.grey : color)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, int id) async {
    // Capture messenger BEFORE any async gap
    final messenger = ScaffoldMessenger.of(context);

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
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.error, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final msg = await _repository.deleteAuction(id);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg ?? 'تم الحذف بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onDeleteSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
