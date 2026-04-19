// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid;

    if (sellerId == null) {
      return const Center(child: Text("Please log in."));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      appBar: AppBar(
        title: customText(20, 'Order Management', fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            // .orderBy('timestamp', descending: true) // Requires an index in Firebase!
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildOrderCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Placed';
    final productImg = data['productImage'] ?? '';
    final productName = data['productName'] ?? 'Unknown Product';
    final totalAmount = data['totalAmount']?.toString() ?? '0.0';
    final qty = data['quantity']?.toString() ?? '1';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(14, 'Order ID: ${orderId.substring(0, 8).toUpperCase()}', fontWeight: FontWeight.bold),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: customText(12, status, webcolors: _getStatusColor(status), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: productImg.isNotEmpty
                      ? Image.network(productImg, width: 80, height: 80, fit: BoxFit.cover)
                      : Container(width: 80, height: 80, color: Colors.grey.shade300, child: const Icon(Icons.image)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(16, productName, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      customText(14, 'Qty: $qty', webcolors: Colors.grey.shade700),
                      const SizedBox(height: 4),
                      customText(16, '₹ $totalAmount', fontWeight: FontWeight.bold, webcolors: WebColors.succesGreen),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showUpdateStatusDialog(context, orderId, status);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WebColors.succesGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Placed':
      case 'Processing': return Colors.orange;
      case 'Shipped': return Colors.blue;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    String orderId,
    String currentStatus,
  ) {
    String selectedStatus = currentStatus;
    // Professional status sequence
    final List<String> statuses = [
      'Placed',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
      'Return Requested',
      'Returned'
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Update Order Status",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: statuses.map((status) {
                      bool isSelected = selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedStatus = status);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        navigator.pop();
                        
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .update({
                              'status': selectedStatus,
                              'lastUpdated': FieldValue.serverTimestamp(),
                            });
                        // No snackbar here since context might unmount, 
                        // and it flips visually instantly due to StreamBuilder tracking!
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
