import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/countdown_timer_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../domain/entities/auction.dart';
import '../bloc/bidding_bloc.dart';
import '../../../../core/widgets/custom_network_image.dart';

class LiveBiddingPage extends StatefulWidget {
  final Auction auction;

  const LiveBiddingPage({super.key, required this.auction});

  @override
  State<LiveBiddingPage> createState() => _LiveBiddingPageState();
}

class _LiveBiddingPageState extends State<LiveBiddingPage> {
  final TextEditingController _bidController = TextEditingController();
  final List<Map<String, dynamic>> _liveBids = [
    {'name': 'سارة أحمد', 'amount': 45500.0, 'time': 'منذ 30 ثانية', 'isMe': false},
    {'name': 'عمرو خالد', 'amount': 45000.0, 'time': 'منذ دقيقة', 'isMe': false},
    {'name': 'ياسر محمد', 'amount': 44800.0, 'time': 'منذ دقيقتين', 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<BiddingBloc, BiddingState>(
      listener: (context, state) {
        if (state is BiddingSuccess) {
          setState(() {
            _liveBids.insert(0, {
              'name': 'أنا',
              'amount': state.newBid,
              'time': 'الآن',
              'isMe': true,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت المزايدة بنجاح!')),
          );
        } else if (state is BiddingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('مزاد مباشر', style: TextStyle(color: Colors.white)),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'مباشر',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildItemBrief(),
            _buildTimerBanner(),
            Expanded(child: _buildBidsList()),
            _buildBiddingPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBrief() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CustomNetworkImage(
            imageUrl: widget.auction.imageUrl,
            width: 60,
            height: 60,
            borderRadius: 8,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.auction.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Text('السعر الحالي: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    PriceWidget(
                      price: widget.auction.currentBid,
                      style: const TextStyle(color: AppColors.priceGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBanner() {
    return Container(
      width: double.infinity,
      color: Colors.white.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: CountdownTimerWidget(
          endTime: widget.auction.endTime,
          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildBidsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _liveBids.length,
      itemBuilder: (context, index) {
        final bid = _liveBids[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              UserAvatar(name: bid['name'], size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bid['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(bid['time'], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              PriceWidget(
                price: bid['amount'],
                style: const TextStyle(color: AppColors.priceGreen, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBiddingPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickBidButton(500),
              _quickBidButton(1000),
              _quickBidButton(2000),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bidController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'أدخل قيمة المزايدة...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              BlocBuilder<BiddingBloc, BiddingState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'مزايدة',
                    width: 100,
                    isLoading: state is BiddingLoading,
                    onPressed: () {
                      if (_bidController.text.isNotEmpty) {
                        final amount = double.tryParse(_bidController.text);
                        if (amount != null) {
                          context.read<BiddingBloc>().add(PlaceBid(amount));
                          _bidController.clear();
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickBidButton(double amount) {
    return InkWell(
      onTap: () => _bidController.text = (widget.auction.currentBid + amount).toString(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text('+ $amount ج.م', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}
