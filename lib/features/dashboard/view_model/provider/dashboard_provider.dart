import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String customer;
  final String amount;
  final String status;
  final String imageUrl;
  final int quantity;

  OrderModel({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.imageUrl,
    required this.quantity,
  });
}

class TopProductModel {
  final String rank;
  final String name;
  final String sales;
  final String imageUrl;

  TopProductModel({
    required this.rank,
    required this.name,
    required this.sales,
    required this.imageUrl,
  });
}

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  // KPI Metrics
  String totalSales = "₹ 0";
  String totalOrders = "0";
  String totalProducts = "0";
  String pendingOrders = "0";
  List<TopProductModel> topProducts = [];
  List<OrderModel> recentOrders = [];
  List<double> monthlySales = List.filled(12, 0.0);

  // Helper to format currency
  final currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
  );

  Future<void> fetchDashboardData(String sellerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Fetch Orders for this seller
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      double salesSum = 0;
      int pendingCount = 0;
      List<OrderModel> retrievedOrders = [];
      Map<String, int> productSalesCount = {};
      Map<String, String> topImagesMap = {};
      Map<String, String> topNamesMap = {};
      List<double> tempMonthlySales = List.filled(12, 0.0);

      final currentYear = DateTime.now().year;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        double amount = (data['totalAmount'] ?? 0).toDouble();
        String status = data['status'] ?? 'Pending';
        int qty = data['quantity'] ?? 1;

        salesSum += amount;
        if (status == 'Placed' || status == 'Pending') {
          pendingCount++;
        }

        // Aggregate Product Sales accurately
        final productId = data['productId'] as String?;
        if (productId != null) {
          productSalesCount[productId] = (productSalesCount[productId] ?? 0) + qty;
          topImagesMap[productId] = data['productImage'] ?? '';
          topNamesMap[productId] = data['productName'] ?? 'Unknown';
        }

        // Aggregate Monthly Sales accurately
        if (data['timestamp'] != null) {
          final timestamp = data['timestamp'] as Timestamp;
          final date = timestamp.toDate();
          if (date.year == currentYear) {
            tempMonthlySales[date.month - 1] += amount;
          }
        }

        // Safely extract customer name from their shipping profile
        final shippingInfo = data['shippingAddress'] as Map<String, dynamic>? ?? {};
        final customerName = shippingInfo['name'] ?? shippingInfo['fullName'] ?? shippingInfo['firstName'] ?? 'Customer';

        retrievedOrders.add(
          OrderModel(
            id: doc.id,
            customer: customerName, 
            amount: currencyFormatter.format(amount),
            status: status,
            imageUrl: data['productImage'] ?? '',
            quantity: qty,
          ),
        );
      }
      monthlySales = tempMonthlySales;

      // 2. Fetch Total Products
      final productsSnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      // 3. Update Metrics
      totalSales = currencyFormatter.format(salesSum);
      totalOrders = ordersSnapshot.docs.length.toString();
      totalProducts = productsSnapshot.docs.length.toString();
      pendingOrders = pendingCount.toString();
      
      // Sort and Take Recent Orders (last 5, descending by timestamp theoretically)
      recentOrders = retrievedOrders.reversed.take(5).toList();

      // 4. Calculate True Top Products
      final sortedProducts = productSalesCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3 = sortedProducts.take(3).toList();
      
      topProducts.clear();
      for (int i = 0; i < top3.length; i++) {
        String accurateImg = topImagesMap[top3[i].key] ?? '';
        if (accurateImg.isEmpty) accurateImg = "https://via.placeholder.com/150";

        topProducts.add(TopProductModel(
          rank: (i + 1).toString(),
          name: topNamesMap[top3[i].key] ?? 'Unknown',
          sales: "${top3[i].value} Sold",
          imageUrl: accurateImg,
        ));
      }

    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateLocalOrderStatus(String orderId, String newStatus) {
    int index = recentOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = recentOrders[index];
      recentOrders[index] = OrderModel(
        id: oldOrder.id,
        customer: oldOrder.customer,
        amount: oldOrder.amount,
        status: newStatus,
        imageUrl: oldOrder.imageUrl,
        quantity: oldOrder.quantity,
      );
      notifyListeners();
    }
  }
}
