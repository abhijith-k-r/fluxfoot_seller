import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/dashboard/view_model/provider/dashboard_provider.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Clean light grey background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ! 1. TOP HEADER (Search & Profile)
              _buildHeader(context),
              
              const SizedBox(height: 32),

              // ! 2. KPI METRIC CARDS
              _buildMetricGrid(size),

              const SizedBox(height: 32),

              // ! 3. MIDDLE SECTION (Chart & Some Other Info)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSalesChart()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildInventoryAlerts()),
                ],
              ),

              const SizedBox(height: 32),

              // ! 4. BOTTOM SECTION (Top Products List)
              _buildTopProductsTable(),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER WITH SEARCH
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(24, 'FluxFoot Dashboard', fontWeight: FontWeight.bold),
            customText(14, 'Welcome back, check your store performance.', webcolors: Colors.grey),
          ],
        ),
        Row(
          children: [
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search dashboard...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.notifications_none, color: Colors.black),
            ),
            // const SizedBox(width: 16),
            // CircleAvatar(
            //   backgroundColor: WebColors.buttonPurple,
            //   child: const Icon(Icons.person, color: Colors.white),
            // ),
          ],
        ),
      ],
    );
  }

  // METRIC CARDS GRID
  Widget _buildMetricGrid(Size size) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: size.width > 1200 ? 4 : (size.width > 800 ? 2 : 1),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 3.0,
          children: [
            _buildMetricCard('Total Revenue', dashboard.totalRevenue, Icons.account_balance_wallet, WebColors.buttonPurple),
            _buildMetricCard('Total Orders', dashboard.totalOrders, Icons.shopping_bag, WebColors.activeOrange),
            _buildMetricCard('Low Stock', dashboard.lowStockItems, Icons.warning_amber_rounded, WebColors.errorRed),
            _buildMetricCard('Customers', dashboard.totalCustomers, Icons.people_alt, WebColors.succesGreen),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customText(14, title, webcolors: Colors.white70),
                const SizedBox(height: 8),
                customText(22, value, fontWeight: FontWeight.bold, webcolors: Colors.white),
              ],
            ),
          ),
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 40),
        ],
      ),
    );
  }

  // SALES CHART
  Widget _buildSalesChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(18, 'Weekly Sales Analytics', fontWeight: FontWeight.bold),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                double height = [120, 180, 140, 240, 210, 280, 220][index].toDouble();
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [WebColors.buttonPurple, WebColors.activeOrange],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      customText(12, ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // INVENTORY ALERTS
  Widget _buildInventoryAlerts() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(18, 'Action Required', fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          _buildAlertItem('Restock Sneakers High Top', '5 units left', WebColors.errorRed),
          _buildAlertItem('Pending Orders Verification', '3 batches', WebColors.activeOrange),
          _buildAlertItem('Update Category Dynamic Fields', 'Category: Sports', WebColors.buttonPurple),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(14, title, fontWeight: FontWeight.w600),
                customText(12, subtitle, webcolors: Colors.grey),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // TOP PRODUCTS TABLE
  Widget _buildTopProductsTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customText(18, 'Top Selling Products', fontWeight: FontWeight.bold),
              TextButton(
                onPressed: () {},
                child: customText(14, 'View All', webcolors: WebColors.buttonPurple),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTableHeader(),
          const Divider(),
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final list = productProvider.products.take(5).toList();
              if (list.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No products found")));
              }
              return Column(
                children: list.map((p) => _buildProductRow(p)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: customText(14, 'PRODUCT', fontWeight: FontWeight.bold, webcolors: Colors.grey)),
          Expanded(child: customText(14, 'CATEGORY', fontWeight: FontWeight.bold, webcolors: Colors.grey)),
          Expanded(child: customText(14, 'PRICE', fontWeight: FontWeight.bold, webcolors: Colors.grey)),
          Expanded(child: customText(14, 'STOCK', fontWeight: FontWeight.bold, webcolors: Colors.grey)),
          Expanded(child: customText(14, 'SALES', fontWeight: FontWeight.bold, webcolors: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductRow(dynamic product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    image: product.images.isNotEmpty 
                      ? DecorationImage(image: NetworkImage(product.images[0]), fit: BoxFit.cover)
                      : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: customText(14, product.name, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(child: customText(14, product.category)),
          Expanded(child: customText(14, "₹ ${product.salePrice}")),
          Expanded(child: customText(14, product.quantity)),
          Expanded(child: customText(14, "85", webcolors: Colors.green, fontWeight: FontWeight.bold)), // Mock sales count
        ],
      ),
    );
  }
}
