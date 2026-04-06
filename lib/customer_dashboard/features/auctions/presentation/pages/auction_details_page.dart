import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_auction/customer_dashboard/core/services/service_locator.dart';
import 'package:live_auction/customer_dashboard/core/theme/app_colors.dart';
import 'package:live_auction/customer_dashboard/core/theme/app_text_styles.dart';
import 'package:live_auction/customer_dashboard/core/widgets/custom_network_image.dart';
import 'package:live_auction/customer_dashboard/core/widgets/price_widget.dart';
import 'package:live_auction/customer_dashboard/core/widgets/primary_button.dart';
import 'package:live_auction/customer_dashboard/core/widgets/user_avatar.dart';

import '../../data/models/bid_model.dart';
import '../../domain/entities/auction.dart';
import '../bloc/auction_bloc.dart';
import '../bloc/bid_history_bloc.dart';

class AuctionDetailsPage extends StatefulWidget {
  final Auction auction;
  final bool isAlreadyJoined;

  const AuctionDetailsPage({
    super.key,
    required this.auction,
    this.isAlreadyJoined = false,
  });

  @override
  State<AuctionDetailsPage> createState() => _AuctionDetailsPageState();
}

class _AuctionDetailsPageState extends State<AuctionDetailsPage> {
  late bool _hasJoined;
  final TextEditingController _bidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hasJoined = widget.isAlreadyJoined;
    // Load bidders when page opens
    context.read<AuctionBloc>().add(LoadAuctionBids(widget.auction.id));
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انضمام للمزاد'),
        content: Text('هل تريد الانضمام لمزاد: ${widget.auction.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuctionBloc>().add(JoinAuction(widget.auction.id));
            },
            child: const Text('انضمام'),
          ),
        ],
      ),
    );
  }

  void _showBidDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تقديم مزايدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('السعر الحالي: ${widget.auction.currentPrice} ج.م'),
              const SizedBox(height: 16),
              TextField(
                controller: _bidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'قيمة المزايدة',
                  prefixText: 'ج.م ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_bidController.text);
                if (amount != null && amount > widget.auction.currentPrice) {
                  Navigator.pop(context);
                  context.read<AuctionBloc>().add(
                    PlaceBid(auctionId: widget.auction.id, amount: amount),
                  );
                  _bidController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'قيمة المزايدة يجب أن تكون أعلى من السعر الحالي',
                      ),
                    ),
                  );
                }
              },
              child: const Text('مزايدة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuctionBloc, AuctionState>(
      listener: (context, state) {
        if (state is JoinAuctionSuccess) {
          setState(() => _hasJoined = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الانضمام للمزاد بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is JoinAuctionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is PlaceBidSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تمت المزايدة بـ ${state.amount} ج.م بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is PlaceBidError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHighestBidderTag(context),
                        const SizedBox(height: 12),
                        Text(
                          widget.auction.title,
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 8),
                        _buildSellerInfo(),
                        const Divider(height: 32),
                        _buildAuctionStats(),
                        const Divider(height: 32),
                        _buildDescription(),
                        const Divider(height: 32),
                        _buildBiddersSection(),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildStickyBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CustomNetworkImage(imageUrl: widget.auction.image ?? ''),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'مباشر الآن',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighestBidderTag(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.priceGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.priceGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'أعلى مزايدة حالياً: ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.priceGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: PriceWidget(
                    price: widget.auction.currentPrice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.priceGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/bid-history',
              arguments: widget.auction,
            );
          },
          icon: const Icon(Icons.history, size: 18),
          label: const Text('سجل المزايدات'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerInfo() {
    return const SizedBox.shrink();
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('وصف المنتج', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text(
          widget.auction.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBiddersSection() {
    return BlocProvider.value(
      value: sl<BidHistoryBloc>(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المشاركون في المزاد', style: AppTextStyles.heading3),
              BlocBuilder<BidHistoryBloc, BidHistoryState>(
                builder: (context, state) {
                  if (state is BidHistoryLoaded) {
                    return TextButton.icon(
                      onPressed: () {
                        context.read<BidHistoryBloc>().add(
                          LoadBidHistory(widget.auction.id),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('تحديث'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocConsumer<BidHistoryBloc, BidHistoryState>(
            listenWhen: (previous, current) =>
                current is BidHistoryLoaded || current is BidHistoryError,
            listener: (context, state) {
              // Handle any side effects if needed
            },
            builder: (context, state) {
              if (state is BidHistoryInitial) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<BidHistoryBloc>().add(
                          LoadBidHistory(widget.auction.id),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('عرض المشاركين'),
                    ),
                  ),
                );
              } else if (state is BidHistoryLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is BidHistoryLoaded) {
                if (state.bids.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('لا يوجد مزايدات حالياً'),
                    ),
                  );
                }
                return _buildBiddersList(state.bids);
              } else if (state is BidHistoryError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('خطأ: ${state.message}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<BidHistoryBloc>().add(
                              LoadBidHistory(widget.auction.id),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBiddersList(List<BidModel> bids) {
    return Column(
      children: bids.map((bid) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: UserAvatar(name: bid.user.fullName, size: 40),
            title: Text(
              bid.user.fullName,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'مزايدة بقيمة ${bid.amount} ج.م',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.priceGreen,
              ),
            ),
            trailing: Text(
              _formatTimeAgo(bid.createdAt),
              style: AppTextStyles.caption,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'منذ لحظات';
    }
  }

  Widget _buildAuctionStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem('حالة المزاد', widget.auction.status),
        _statItem('المشاركون', '42'),
        _statItem('الحالة', 'نشط'),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    // Hide bottom bar for closed or paid auctions
    if (widget.auction.status == 'closed' || widget.auction.status == 'paid') {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: PrimaryButton(
          text: _hasJoined ? 'تقديم مزايدة' : 'انضمام للمزاد',
          onPressed: _hasJoined ? _showBidDialog : _showJoinDialog,
        ),
      ),
    );
  }
}
