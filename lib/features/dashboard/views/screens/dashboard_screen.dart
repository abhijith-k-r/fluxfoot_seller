// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/dashboard/view_model/provider/dashboard_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on Load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seller = FirebaseAuth.instance.currentUser;
      if (seller != null) {
        Provider.of<DashboardProvider>(
          context,
          listen: false,
        ).fetchDashboardData(seller.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final sellerId = FirebaseAuth.instance.currentUser?.uid;
                if (sellerId != null) {
                  await provider.fetchDashboardData(sellerId);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    customText(
                      24,
                      'Dashboard',
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 24),

                    // Metric Grid
                    _buildMetricGrid(context),

                    const SizedBox(height: 24),

                    // Middle Section (Charts & Top Products)
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildSalesOverview(context),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildTopSellingProducts(context),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildSalesOverview(context),
                          const SizedBox(height: 24),
                          _buildTopSellingProducts(context),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Bottom Section (Recent Orders)
                    _buildRecentOrders(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricGrid(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final size = MediaQuery.of(context).size;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: size.width > 1200 ? 5 : (size.width > 800 ? 3 : 1),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 2.5,
      children: [
        _buildMetricCard(
          title: 'Total Sales',
          value: provider.totalSales,
          icon: Icons.attach_money,
          color: const Color(0xFF43A047),
        ),
        _buildMetricCard(
          title: 'Total Orders',
          value: provider.totalOrders,
          icon: Icons.inventory_2,
          color: const Color(0xFF1E88E5),
        ),
        _buildMetricCard(
          title: 'Total Products',
          value: provider.totalProducts,
          icon: Icons.checkroom,
          color: const Color(0xFFF4511E),
        ),
        _buildMetricCard(
          title: 'Returned Products',
          value: provider.returnedProductsCount,
          icon: Icons.assignment_return,
          color: const Color(0xFFD32F2F),
          onTap: () => _showReturnedProductsDialog(context, provider),
        ),
        _buildMetricCard(
          title: 'Wallet Balance',
          value: provider.walletBalance,
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF673AB7), // Deep Purple for Wallet
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customText(
                      16,
                      title,
                      webcolors: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 4),
                    customText(
                      24,
                      value,
                      webcolors: Colors.white,
                      fontWeight: FontWeight.bold,
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

  void _showReturnedProductsDialog(
    BuildContext context,
    DashboardProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Returned Products Detail"),
        content: SizedBox(
          width: 500,
          child: provider.returnedOrdersList.isEmpty
              ? const Center(child: Text("No returned products found."))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: provider.returnedOrdersList.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = provider.returnedOrdersList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: order.imageUrl.isNotEmpty
                                    ? Image.network(
                                        order.imageUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey.shade200,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.customer,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Order ID: ${order.id.substring(0, 8).toUpperCase()}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                order.amount,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Reason for Return:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  order.returnReason,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Status: ${order.status}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOverview(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    // Scale Graph Y Max bounds dynamically
    double maxY = 1000;
    if (provider.monthlySales.isNotEmpty) {
      double maxAmount = provider.monthlySales.reduce(
        (curr, next) => curr > next ? curr : next,
      );
      maxY = maxAmount > 0 ? maxAmount * 1.2 : 1000;
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(18, 'Sales Overview', fontWeight: FontWeight.bold),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        if (value >= 1000) {
                          return customText(
                            11,
                            '₹${(value / 1000).toStringAsFixed(1)}k',
                            webcolors: Colors.grey,
                          );
                        }
                        return customText(
                          11,
                          '₹${value.toInt()}',
                          webcolors: Colors.grey,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        );
                        final months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        if (value >= 0 && value < 12) {
                          return Text(months[value.toInt()], style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(12, (index) {
                      return FlSpot(
                        index.toDouble(),
                        provider.monthlySales[index],
                      );
                    }),
                    isCurved: true,
                    color: const Color(0xFF43A047),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF43A047),
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF43A047).withOpacity(0.3),
                          const Color(0xFF43A047).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildTopSellingProducts(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(18, 'Top Selling Products', fontWeight: FontWeight.bold),
          const SizedBox(height: 24),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: provider.topProducts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = provider.topProducts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          width: 60,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade200,
                            width: 60,
                            height: 45,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customText(
                              14,
                              '${product.rank}. ${product.name}',
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      customText(
                        14,
                        product.sales,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(18, 'Recent Orders', fontWeight: FontWeight.bold),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 60,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
              columns: [
                DataColumn(
                  label: customText(
                    14,
                    'Image',
                    fontWeight: FontWeight.bold,
                    webcolors: Colors.grey.shade700,
                  ),
                ),
                DataColumn(
                  label: customText(
                    14,
                    'Order ID',
                    fontWeight: FontWeight.bold,
                    webcolors: Colors.grey.shade700,
                  ),
                ),
                DataColumn(
                  label: customText(
                    14,
                    'Customer',
                    fontWeight: FontWeight.bold,
                    webcolors: Colors.grey.shade700,
                  ),
                ),
                DataColumn(
                  label: customText(
                    14,
                    'Amount',
                    fontWeight: FontWeight.bold,
                    webcolors: Colors.grey.shade700,
                  ),
                ),
                DataColumn(
                  label: customText(
                    14,
                    'Qty',
                    fontWeight: FontWeight.bold,
                    webcolors: Colors.grey.shade700,
                  ),
                ),
                DataColumn(
                  label: customText(
                    14,
                    'Status',
                    fontWeight: FontWeight.bold,
                    webcolors: Colors.grey.shade700,
                  ),
                ),
              ],
              rows: provider.recentOrders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: order.imageUrl.isNotEmpty
                            ? Image.network(
                                order.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 20),
                              ),
                      ),
                    ),
                    DataCell(
                      customText(
                        14,
                        order.id.substring(0, 8).toUpperCase(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    DataCell(customText(14, order.customer)),
                    DataCell(customText(14, order.amount)),
                    DataCell(customText(14, "x${order.quantity}")),
                    DataCell(_buildStatusBadge(order.status)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Shipped':
        color = const Color(0xFF43A047);
        break;
      case 'Processing':
        color = const Color(0xFFF4511E);
        break;
      case 'Delivered':
        color = const Color(0xFF1E88E5);
        break;
      case 'Cancelled':
      case 'Return Requested':
      case 'Returned':
        color = const Color(0xFFD32F2F);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: customText(
        12,
        status,
        webcolors: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
