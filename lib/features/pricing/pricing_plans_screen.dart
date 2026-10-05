import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class PricingPlansScreen extends StatelessWidget {
  const PricingPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        title: const Text('StockSense Enterprise Plans & Cost Estimator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text('Flexible Plans for Modern Supply Chains',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Scale your logistics control room from single bin to multi-warehouse network.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _planCard(context, 'Starter', '₹5,000 / mo', 'Small Warehouse', ['Up to 500 SKUs', '2 User Licenses', 'Basic Barcode Scan'], isDark),
                const SizedBox(width: 12),
                _planCard(context, 'Growth', '₹18,000 / mo', 'Mid-Size Hub', ['Up to 5,000 SKUs', '10 User Licenses', '2D Interactive Map', 'Offline Sync'], isDark, isFeatured: true),
                const SizedBox(width: 12),
                _planCard(context, 'Scale', '₹50,000 / mo', 'Enterprise Logistics', ['Unlimited SKUs', 'Unlimited Users', 'AI Smart Velocity Insights', '24/7 SLA Support'], isDark),
              ],
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interactive Cost Estimator', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Estimated Monthly Fee: ₹18,000 / month (Includes Growth License + 10 Users)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(BuildContext context, String title, String price, String sub, List<String> features, bool isDark, {bool isFeatured = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFeatured ? AppColors.primaryTeal.withValues(alpha: 0.15) : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isFeatured ? AppColors.primaryTeal : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: isFeatured ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryTeal)),
            const SizedBox(height: 12),
            ...features.map((f) => Text('• $f', style: const TextStyle(fontSize: 11))),
          ],
        ),
      ),
    );
  }
}
