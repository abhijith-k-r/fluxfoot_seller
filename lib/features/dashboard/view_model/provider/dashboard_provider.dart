import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String customer;
  final String amount;
  final String status;

  OrderModel({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
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
  bool _isLoading = false;
  bool get isLoading => _isLoading;


  // KPI Metrics
  String totalSales = "₹ 12,540";
  String totalOrders = "350";
  String totalProducts = "45";
  String pendingOrders = "18";

  // Chart Data (Mock - simple y values)
  final List<double> monthlySales = [1.2, 1.8, 1.4, 2.5, 2.0, 2.3, 2.8, 3.5, 2.9];

  // Top Products
  final List<TopProductModel> topProducts = [
    TopProductModel(rank: "1", name: "Adidas Predator Boots", sales: "120 Sales", imageUrl: "https://assets.adidas.com/images/h_840,f_auto,q_auto,fl_lossy,c_fill,g_auto/77a330bf425848bbabae96901869e54d_9366/Predator_Accuracy.3_Low_Firm_Ground_Boots_Black_IE9439_01_standard.jpg"),
    TopProductModel(rank: "2", name: "Real Madrid Jersey", sales: "95 Sales", imageUrl: "https://shop.realmadrid.com/cdn/shop/files/RMCFMT0124-01_1_800x.jpg"),
    TopProductModel(rank: "3", name: "Nike Football", sales: "80 Sales", imageUrl: "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:heavy/f3f159a6-1246-466d-8e43-157999813f8f/pitch-football-Lp6Xf7.png"),
  ];

  // Recent Orders
  final List<OrderModel> recentOrders = [
    OrderModel(id: "#10234", customer: "John Smith", amount: "₹ 150.00", status: "Shipped"),
    OrderModel(id: "#10233", customer: "Sarah Lee", amount: "₹ 85.00", status: "Processing"),
    OrderModel(id: "#10232", customer: "Mike Johnson", amount: "₹ 220.00", status: "Delivered"),
    OrderModel(id: "#10231", customer: "Emma Davis", amount: "₹ 65.00", status: "Cancelled"),
  ];

  void refreshDashboard() {
    _isLoading = true;
    notifyListeners();
    
    // Simulate data fetch
    Future.delayed(const Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }
}

