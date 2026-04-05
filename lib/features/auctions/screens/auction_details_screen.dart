import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/auction_model.dart';
import '../models/auction_bid_model.dart';
import '../repositories/auctions_repository.dart';
import 'package:intl/intl.dart';

class AuctionDetailsScreen extends StatefulWidget {
  final int id;

  const AuctionDetailsScreen({super.key, required this.id});

  @override
  State<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends State<AuctionDetailsScreen> {
  late Future<AuctionModel> _auctionFuture;
  late Future<List<AuctionBidModel>> _bidsFuture;
  final AuctionsRepository _repository = AuctionsRepository();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _joinAuction(int id) async {
    setState(() {
      _isJoining = true;
    });

    try {
      final result = await _repository.joinAuction(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(result['message'] ?? 'تم الانضمام بنجاح')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchData();
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
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  void _fetchData() {
    setState(() {
      _auctionFuture = _repository.fetchAuctionById(widget.id);
      _bidsFuture = _repository.fetchAuctionBids(widget.id);
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'غير متوفر';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd HH:mm').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('تفاصيل المزاد', style: AppTextStyles.h2),
        leading: const BackButton(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: FutureBuilder<AuctionModel>(
        future: _auctionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _fetchData,
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('المزاد غير متوفر'));
          }

          final auction = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: auction.imageUrl != null
                        ? Image.network(
                            auction.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, _, __) => const Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(auction.title, style: AppTextStyles.h2),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        auction.status.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (auction.description != null &&
                    auction.description!.isNotEmpty) ...[
                  Text('الوصف', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    auction.description!,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Data Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('رقم المزاد (ID)', '#${auction.id}'),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'السعر المبدئي',
                        '\$${auction.startPrice.toStringAsFixed(2)}',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'السعر الحالي',
                        '\$${(auction.currentPrice ?? auction.startPrice).toStringAsFixed(2)}',
                        isHighlight: true,
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'رسوم الدخول',
                        auction.entryFee != null
                            ? '\$${auction.entryFee!.toStringAsFixed(2)}'
                            : 'مجانًا',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'وقت البدء',
                        _formatDate(auction.startTime),
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'وقت الانتهاء',
                        _formatDate(auction.endTime),
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'موعد الإغلاق الفعلي',
                        auction.closedAt != null
                            ? _formatDate(auction.closedAt!)
                            : 'لم يغلق بعد',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'تاريخ الاضافة',
                        _formatDate(auction.createdAt),
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'آخر تحديث',
                        _formatDate(auction.updatedAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Members Information
                Text('معلومات إضافية', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'تم الإنشاء بواسطة (رقم)',
                        '#${auction.createdBy}',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'أعلى مزايد (رقم)',
                        auction.highestBidderId != null
                            ? '#${auction.highestBidderId}'
                            : 'لا يوجد',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'الفائز (رقم)',
                        auction.winnerId != null
                            ? '#${auction.winnerId}'
                            : 'لم يحدد',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'حالة الدفع',
                        auction.paymentStatus ?? 'قيد الانتظار',
                      ),
                      const Divider(color: AppColors.border),
                      _buildDetailRow(
                        'آخر موعد للدفع',
                        auction.paymentDeadline != null
                            ? _formatDate(auction.paymentDeadline!)
                            : 'غير محدد',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('المزايدات الحالية', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _buildBidsWidget(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<AuctionModel>(
        future: _auctionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final auction = snapshot.data!;

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ElevatedButton(
              onPressed: _isJoining ? null : () => _joinAuction(auction.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isJoining
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'الانضمام للمزاد',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: isHighlight
                ? AppTextStyles.body1Bold.copyWith(color: AppColors.primary)
                : AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Widget _buildBidsWidget() {
    return FutureBuilder<List<AuctionBidModel>>(
      future: _bidsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    snapshot.error.toString().replaceAll('Exception: ', ''),
                    style: AppTextStyles.body2.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.gavel_rounded, color: AppColors.textSecondary, size: 40),
                const SizedBox(height: 8),
                Text('لا توجد مزايدات حتى الآن', style: AppTextStyles.body1),
              ],
            ),
          );
        }

        final bids = snapshot.data!;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bids.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final bid = bids[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: bid.user?.profileImage != null ? NetworkImage(bid.user!.fullProfileImageUrl) : null,
                  child: bid.user?.profileImage == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                title: Text(bid.user?.fullName ?? 'مستخدم #${bid.userId}', style: AppTextStyles.body1Bold),
                subtitle: Text(_formatDate(bid.createdAt), style: AppTextStyles.caption),
                trailing: Text('\$${bid.amount.toStringAsFixed(2)}', style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
              );
            },
          ),
        );
      },
    );
  }
}
