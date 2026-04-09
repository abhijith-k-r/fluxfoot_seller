import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // KPI Metrics
  String totalRevenue = "₹ 4,52,000";
  String totalOrders = "1,240";
  String lowStockItems = "12";
  String totalCustomers = "890";

  // Chart Data (Mock)
  final List<double> weeklySales = [30, 45, 35, 60, 55, 80, 70];

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
