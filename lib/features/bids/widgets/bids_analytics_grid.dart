import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BidsAnalyticsGrid extends StatelessWidget {
  const BidsAnalyticsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 1,
      mainAxisSpacing: 16,
      children: [
        _buildAnalyticsCard(
          'أعلى ٣ مزايدات',
          Icons.trending_up_rounded,
          AppColors.primary,
          [
            {'label': '١. @شيف_م', 'value': '\$٧,٤٠٠'},
            {'label': '٢. @كافيه_روست', 'value': '\$٦,٨٠٠'},
            {'label': '٣. @بيتزايولو', 'value': '\$٥,٢٠٠'},
          ],
        ),
        _buildAnalyticsCard(
          'أحدث المزايدات',
          Icons.access_time_rounded,
          Colors.greenAccent,
          [
            {'label': 'منذ ١٠ د', 'value': '\$٧,٤٠٠'},
            {'label': 'منذ ٢٥ د', 'value': '\$٣,٤٥٠'},
            {'label': 'منذ ١ س', 'value': '\$٢,١٠٠'},
          ],
        ),
        _buildAnalyticsCard(
          'الأكثر نشاطا',
          Icons.emoji_events_rounded,
          Colors.purpleAccent,
          [
            {'label': '١. @شيف_م', 'value': '٤٥ مزايدة'},
            {'label': '٢. @سارة_خالد', 'value': '٣٨ مزايدة'},
            {'label': '٣. @عمر_حسن', 'value': '٣٢ مزايدة'},
          ],
        ),
        _buildAnalyticsCard(
          'المزادات الساخنة',
          Icons.local_fire_department_rounded,
          Colors.orangeAccent,
          [
            {'label': 'ماكينة إسبريسو', 'value': '٢٣ مزايدة'},
            {'label': 'فرن بيتزا', 'value': '١٨ مزايدة'},
            {'label': 'خلاط تجاري', 'value': '١٥ مزايدة'},
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, IconData icon, Color color, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.body1Bold),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label']!, style: AppTextStyles.body2),
                Text(item['value']!, style: AppTextStyles.body1Bold.copyWith(color: color, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
