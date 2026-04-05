import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -----------------------------------------------------------------------------
// MAIN.DART INTEGRATION EXAMPLE
// -----------------------------------------------------------------------------
/*
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LeaderboardScreen(),
  ));
}
*/

// -----------------------------------------------------------------------------
// THEME & CONSTANTS
// -----------------------------------------------------------------------------

class LeaderboardTheme {
  static const Color bg = Color(0xFF0F0E12);
  static const Color surface = Color(0xFF1A191F);
  static const Color card = Color(0xFF222127);
  static const Color border = Color(0xFF2F2E36);

  static const Color amber = Color(0xFFF57C42);
  static const Color orange = Color(0xFFEA580C);
  
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFFA855F7);
  static const Color yellow = Color(0xFFF59E0B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: amber,
        secondary: orange,
        surface: surface,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  String selectedFilter = 'الكل';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LeaderboardTheme.darkTheme,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: LeaderboardTheme.bg,
          drawer: const ResponsiveSidebar(),
          body: Row(
            children: [
              if (MediaQuery.of(context).size.width >= 1024)
                const SidebarContent(isDrawer: false),
              
              Expanded(
                child: Column(
                  children: [
                    Header(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fixed Header Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: Column(
                              children: [
                                const PageHeader(),
                                const SizedBox(height: 20),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: LeaderboardTheme.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: LeaderboardTheme.border),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      color: LeaderboardTheme.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.white38,
                                    labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                                    onTap: (index) => setState(() {}),
                                    tabs: const [
                                      Tab(text: 'التصنيف'),
                                      Tab(text: 'الإحصائيات'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Scrollable Content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Ranking View
                                _buildRankingTab(),
                                
                                // Tab 2: Analytics View
                                _buildAnalyticsTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          FilterBar(
            selectedFilter: selectedFilter,
            onFilterChanged: (val) => setState(() => selectedFilter = val),
          ),
          const SizedBox(height: 24),
          const TopThreeSection(),
          const SizedBox(height: 24),
          const LeaderboardTableSection(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          const StatsGrid(),
          const SizedBox(height: 24),
          const ExtraGridSection(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COMPONENTS
// -----------------------------------------------------------------------------

class Header extends StatelessWidget {
  final VoidCallback onMenuPressed;
  const Header({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: LeaderboardTheme.surface,
        border: Border(bottom: BorderSide(color: LeaderboardTheme.border)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LeaderboardTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لوحة المتصدرين', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('أفضل المستخدمين والمزايدين على المنصة', 
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مستخدم...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: LeaderboardTheme.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: LeaderboardTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: LeaderboardTheme.border),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (!isDesktop) const Spacer(),
          const SizedBox(width: 8),
          // Actions
          _headerAction(Icons.notifications_none, badge: '5'),
          const SizedBox(width: 6),
          _headerAction(Icons.nightlight_round),
          const SizedBox(width: 6),
          // Profile
          Container(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 6, vertical: isDesktop ? 6 : 4),
            decoration: BoxDecoration(
              color: LeaderboardTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: LeaderboardTheme.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: isDesktop ? 32 : 24,
                    height: isDesktop ? 32 : 24,
                    color: Colors.amber.withOpacity(0.2),
                    child: Icon(Icons.person, size: isDesktop ? 20 : 16, color: Colors.amber),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 8),
                  Text('أحمد', style: GoogleFonts.cairo(fontWeight: FontWeight.w500, fontSize: 14)),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white38),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, {String? badge}) {
    return Stack(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: LeaderboardTheme.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LeaderboardTheme.border),
          ),
          child: Icon(icon, color: Colors.white54, size: 18),
        ),
        if (badge != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleSection(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _actionButton('تحديث', Icons.sync, isPrimary: true)),
              const SizedBox(width: 12),
              Expanded(child: _actionButton('تصدير', Icons.file_download)),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _titleSection(),
        Row(
          children: [
            _actionButton('تحديث', Icons.sync, isPrimary: true),
            const SizedBox(width: 12),
            _actionButton('تصدير', Icons.file_download),
          ],
        ),
      ],
    );
  }

  Widget _titleSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LeaderboardTheme.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events, color: LeaderboardTheme.amber, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لوحة المتصدرين', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('أفضل المستخدمين في المزايدات والفوز بالمزادات', 
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? LeaderboardTheme.orange : LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: isPrimary ? null : Border.all(color: LeaderboardTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.white38),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, 
            color: isPrimary ? Colors.white : Colors.white60)),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  const FilterBar({super.key, required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _filterChip('الكل'),
        _filterChip('هذا الشهر'),
        _filterChip('هذا الأسبوع'),
        _filterChip('هذا العام'),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: LeaderboardTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LeaderboardTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('جميع الفئات', style: GoogleFonts.cairo(fontSize: 13, color: Colors.white60)),
              const SizedBox(width: 24),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white38),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    final isSelected = selectedFilter == label;
    return InkWell(
      onTap: () => onFilterChanged(label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? LeaderboardTheme.amber : LeaderboardTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: LeaderboardTheme.border),
        ),
        child: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13, color: isSelected ? Colors.white : Colors.white54)),
      ),
    );
  }
}

class TopThreeSection extends StatelessWidget {
  const TopThreeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return const Column(
            children: [
              LeaderboardTopCard(rank: 1, name: 'أحمد محمد', username: 'ahmad_chef', rating: 5.0, bids: 234, wins: 42, value: '245,800', categories: ['ماكينات اسبريسو', 'أفران', 'ثلاجات']),
              SizedBox(height: 24),
              LeaderboardTopCard(rank: 2, name: 'سارة خالد', username: 'sara_khaled', rating: 4.8, bids: 156, wins: 28, value: '128,400', categories: ['ماكينات اسبريسو', 'أفران']),
              SizedBox(height: 24),
              LeaderboardTopCard(rank: 3, name: 'عمر حسن', username: 'omar_hassan', rating: 4.2, bids: 98, wins: 15, value: '78,900', categories: ['خلاطات', 'قلايات']),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: LeaderboardTopCard(rank: 2, name: 'سارة خالد', username: 'sara_khaled', rating: 4.8, bids: 156, wins: 28, value: '128,400', categories: ['ماكينات اسبريسو', 'أفران'])),
            const SizedBox(width: 24),
            const Expanded(child: LeaderboardTopCard(rank: 1, name: 'أحمد محمد', username: 'ahmad_chef', rating: 5.0, bids: 234, wins: 42, value: '245,800', categories: ['ماكينات اسبريسو', 'أفران', 'ثلاجات'])),
            const SizedBox(width: 24),
            const Expanded(child: LeaderboardTopCard(rank: 3, name: 'عمر حسن', username: 'omar_hassan', rating: 4.2, bids: 98, wins: 15, value: '78,900', categories: ['خلاطات', 'قلايات'])),
          ],
        );
      },
    );
  }
}

class LeaderboardTopCard extends StatelessWidget {
  final int rank;
  final String name;
  final String username;
  final double rating;
  final int bids;
  final int wins;
  final String value;
  final List<String> categories;

  const LeaderboardTopCard({
    super.key, 
    required this.rank, 
    required this.name, 
    required this.username, 
    required this.rating, 
    required this.bids, 
    required this.wins, 
    required this.value, 
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final rankColor = rank == 1 ? LeaderboardTheme.amber : (rank == 2 ? const Color(0xFF94A3B8) : const Color(0xFFB45309));
    
    return Container(
      decoration: BoxDecoration(
        color: LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isFirst ? LeaderboardTheme.amber : LeaderboardTheme.border, width: isFirst ? 2 : 1),
        boxShadow: isFirst ? [BoxShadow(color: LeaderboardTheme.amber.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))] : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Corner Gradient Decoration
          Positioned(
            top: -20,
            left: -20,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(-12 / 360),
              child: Container(
                width: isFirst ? 140 : 100,
                height: isFirst ? 140 : 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [rankColor, rankColor.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
          ),
          // Crown/Medal Icon
          Positioned(
            top: 16,
            left: 16,
            child: Icon(
              isFirst ? Icons.workspace_premium : Icons.military_tech,
              color: isFirst ? Colors.amberAccent : rankColor,
              size: isFirst ? 32 : 28,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, isFirst ? 48 : 40, 24, 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      'https://ui-avatars.com/api/?name=User&background=${rankColor.value.toRadixString(16).substring(2)}&color=fff&size=128',
                      width: isFirst ? 80 : 70,
                      height: isFirst ? 80 : 70,
                      errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: rankColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: isFirst ? 22 : 18)),
                Text('@$username', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        i < rating.floor() ? Icons.star : (i < rating ? Icons.star_half_outlined : Icons.star_border),
                        color: Colors.amber,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
                    Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _miniStat('مزايدة', bids.toString(), LeaderboardTheme.info),
                    const SizedBox(width: 12),
                    _miniStat('فوز', wins.toString(), LeaderboardTheme.success),
                  ],
                ),
                const SizedBox(height: 20),
                Text('إجمالي المزايدات', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13)),
                Text('\$$value', style: GoogleFonts.cairo(color: LeaderboardTheme.amber, fontWeight: FontWeight.bold, fontSize: isFirst ? 24 : 20)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: categories.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(c, style: GoogleFonts.cairo(fontSize: 10, color: rankColor)),
                  )).toList(),
                ),
              ],
            ),
          ),
          // Bottom Accent Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [rankColor, rankColor.withOpacity(0.5)]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: LeaderboardTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            Text(label, style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1100 ? 2 : 4);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: const [
            StatCard(label: 'إجمالي المزايدات', value: '1,456', icon: Icons.gavel, color: Colors.blue, growth: '+25%'),
            StatCard(label: 'مزادات فائزة', value: '234', icon: Icons.emoji_events, color: Colors.green, growth: '+18%'),
            StatCard(label: 'مستخدم نشط', value: '890', icon: Icons.people, color: Colors.purple, growth: '+42'),
            StatCard(label: 'قيمة المزايدات', value: '1.2', icon: Icons.attach_money, color: Colors.amber, growth: '+32%'),
          ],
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String growth;

  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, required this.growth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LeaderboardTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                child: Text(growth, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 24)),
          Text(label, style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}

class LeaderboardTableSection extends StatelessWidget {
  const LeaderboardTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LeaderboardTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تصنيف المتصدرين', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _tableTab('الكل'),
                          _tableTab('هذا الشهر'),
                          _tableTab('هذا الأسبوع', isActive: true),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تصنيف المتصدرين', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
                  Row(
                    children: [
                      _tableTab('الكل'),
                      _tableTab('هذا الشهر'),
                      _tableTab('هذا الأسبوع', isActive: true),
                    ],
                  ),
                ],
              );
            }),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(LeaderboardTheme.surface),
              dataRowHeight: 70,
              dividerThickness: 0.5,
              columns: [
                DataColumn(label: _colLabel('الترتيب')),
                DataColumn(label: _colLabel('المستخدم')),
                DataColumn(label: _colLabel('المزايدات')),
                DataColumn(label: _colLabel('الفوز')),
                DataColumn(label: _colLabel('نسبة الفوز')),
                DataColumn(label: _colLabel('إجمالي المزايدات')),
                DataColumn(label: _colLabel('التقييم')),
                DataColumn(label: _colLabel('الفئة المفضلة')),
              ],
              rows: [
                _leaderRow(1, 'أحمد محمد', 'ahmad_chef', 234, 42, 18, '245.8k', 5.0, 'ماكينات اسبريسو', LeaderboardTheme.amber),
                _leaderRow(2, 'سارة خالد', 'sara_khaled', 156, 28, 18, '128.4k', 4.8, 'أفران', const Color(0xFF94A3B8)),
                _leaderRow(3, 'عمر حسن', 'omar_hassan', 98, 15, 15, '78.9k', 4.2, 'خلاطات', const Color(0xFFB45309)),
                _leaderRow(4, 'نورة عبدالله', 'noura_abd', 87, 12, 14, '65.3k', 4.0, 'ثلاجات', Colors.white24),
                _leaderRow(5, 'فهد سعد', 'fahad_saad', 65, 9, 14, '45.2k', 3.8, 'قلايات', Colors.white24),
              ],
            ),
          ),
          // Pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    Text('عرض 1-5 من 42 متصدر', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _pageBtn(Icons.chevron_right),
                          _pageBtn('1', isActive: true),
                          _pageBtn('2'),
                          _pageBtn('3'),
                          _pageBtn('4'),
                          _pageBtn(Icons.chevron_left),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('عرض 1-5 من 42 متصدر', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13)),
                  Row(
                    children: [
                      _pageBtn(Icons.chevron_right),
                      _pageBtn('1', isActive: true),
                      _pageBtn('2'),
                      _pageBtn('3'),
                      _pageBtn('4'),
                      _pageBtn(Icons.chevron_left),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _colLabel(String label) => Text(label, style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold));

  DataRow _leaderRow(int rank, String name, String username, int bids, int wins, int winRate, String total, double rating, String category, Color rankColor) {
    return DataRow(cells: [
      DataCell(Container(
        width: 30, height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
        child: Text(rank.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      )),
      DataCell(Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://ui-avatars.com/api/?name=User&background=random&color=fff',
              width: 36,
              height: 36,
              errorBuilder: (c, e, s) => Container(width: 36, height: 36, color: Colors.amber),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('@$username', style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ],
          ),
        ],
      )),
      DataCell(Text(bids.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(wins.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent))),
      DataCell(Row(
        children: [
          Text('$winRate%', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            width: 60, height: 6,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: winRate / 100,
              child: Container(decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      )),
      DataCell(Text('\$$total', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
      DataCell(Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 4),
          Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: rankColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
        child: Text(category, style: GoogleFonts.cairo(color: rankColor == Colors.white24 ? Colors.white70 : rankColor, fontSize: 10)),
      )),
    ]);
  }

  Widget _tableTab(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? LeaderboardTheme.amber : LeaderboardTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: LeaderboardTheme.border),
      ),
      child: Text(label, style: GoogleFonts.cairo(fontSize: 12, color: isActive ? Colors.white : Colors.white38)),
    );
  }

  Widget _pageBtn(dynamic child, {bool isActive = false}) {
    return Container(
      width: 36, height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? LeaderboardTheme.amber : LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: LeaderboardTheme.border),
      ),
      child: child is IconData 
        ? Icon(child, size: 18, color: Colors.white54)
        : Text(child.toString(), style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
    );
  }
}

class ExtraGridSection extends StatelessWidget {
  const ExtraGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return const Column(
            children: [
              ActiveCategoriesWidget(),
              SizedBox(height: 16),
              FastGrowthWidget(),
              SizedBox(height: 16),
              WeeklyAchievementsWidget(),
            ],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ActiveCategoriesWidget()),
            SizedBox(width: 16),
            Expanded(child: FastGrowthWidget()),
            SizedBox(width: 16),
            Expanded(child: WeeklyAchievementsWidget()),
          ],
        );
      },
    );
  }
}

class ActiveCategoriesWidget extends StatelessWidget {
  const ActiveCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LeaderboardTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fireplace, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text('أكثر الفئات نشاطاً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _catProgress('ماكينات اسبريسو', '456 مزايدة', 0.85),
          _catProgress('أفران', '389 مزايدة', 0.72),
          _catProgress('ثلاجات', '245 مزايدة', 0.45),
          _catProgress('خلاطات', '198 مزايدة', 0.37),
        ],
      ),
    );
  }

  Widget _catProgress(String label, String value, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(fontSize: 12, color: LeaderboardTheme.amber, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: percent,
              child: Container(decoration: BoxDecoration(color: LeaderboardTheme.amber, borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}

class FastGrowthWidget extends StatelessWidget {
  const FastGrowthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LeaderboardTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text('أسرع نمو هذا الأسبوع', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _growthItem('لمى عمر', '+23 مزايدة', '+125%', Colors.pinkAccent),
          _growthItem('ياسر الزهراني', '+18 مزايدة', '+98%', Colors.tealAccent),
          _growthItem('هيا الغامدي', '+15 مزايدة', '+76%', Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _growthItem(String name, String stat, String growth, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(width: 40, height: 40, color: color, alignment: Alignment.center, child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(stat, style: const TextStyle(fontSize: 12, color: Colors.white24)),
              ],
            ),
          ),
          Text(growth, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class WeeklyAchievementsWidget extends StatelessWidget {
  const WeeklyAchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LeaderboardTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LeaderboardTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: Colors.yellow, size: 20),
              const SizedBox(width: 8),
              Text('إنجازات الأسبوع', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _achievement('أحمد محمد', 'أكثر من فاز بالمزادات (7)', Icons.workspace_premium, Colors.amber),
          _achievement('سارة خالد', 'أكثر من قام بمزايدة (45)', Icons.rocket_launch, Colors.blue),
          _achievement('عمر حسن', 'أعلى قيمة مزايدات (\$34,000)', Icons.diamond, Colors.green),
        ],
      ),
    );
  }

  Widget _achievement(String name, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LeaderboardTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SIDEBAR (Drawer / Desktop Sidebar)
// -----------------------------------------------------------------------------

class ResponsiveSidebar extends StatelessWidget {
  const ResponsiveSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: LeaderboardTheme.surface,
      width: 280,
      child: SidebarContent(isDrawer: true),
    );
  }
}

class SidebarContent extends StatelessWidget {
  final bool isDrawer;
  const SidebarContent({super.key, required this.isDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: LeaderboardTheme.surface,
        border: Border(left: BorderSide(color: LeaderboardTheme.border)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LeaderboardTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 22),
                    children: const [
                      TextSpan(text: 'مزاد', style: TextStyle(color: Colors.amber)),
                      TextSpan(text: 'المعدات', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: const [
                SidebarMenuItem(icon: Icons.pie_chart_outline, label: 'لوحة التحكم'),
                SidebarMenuItem(icon: Icons.gavel, label: 'المزادات'),
                SidebarMenuItem(icon: Icons.add_circle_outline, label: 'إنشاء مزاد'),
                SidebarMenuItem(icon: Icons.people_outline, label: 'المستخدمين'),
                SidebarMenuItem(icon: Icons.list_alt, label: 'المزايدات'),
                SidebarMenuItem(icon: Icons.account_balance_wallet_outlined, label: 'المحفظة'),
                SidebarMenuItem(icon: Icons.notifications_none, label: 'الإشعارات'),
                SidebarMenuItem(icon: Icons.emoji_events, label: 'المتصدرون', isActive: true),
                SidebarMenuItem(icon: Icons.settings_outlined, label: 'الإعدادات'),
              ],
            ),
          ),
          // User Card Profile
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LeaderboardTheme.card.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://ui-avatars.com/api/?name=Admin&background=c2410c&color=fff&bold=true',
                      width: 40,
                      height: 40,
                      errorBuilder: (c, e, s) => Container(width: 40, height: 40, color: Colors.amber),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد المدير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('admin@auction.com', style: TextStyle(color: Colors.white24, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const SidebarMenuItem({super.key, required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isActive ? LinearGradient(colors: [Colors.amber.withOpacity(0.1), Colors.transparent]) : null,
        border: isActive ? const Border(right: BorderSide(color: Colors.amber, width: 4)) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {},
        leading: Icon(icon, color: isActive ? Colors.amber : Colors.white38, size: 22),
        title: Text(label, style: GoogleFonts.cairo(color: isActive ? Colors.amber : Colors.white54, fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
