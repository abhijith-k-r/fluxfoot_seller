// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            // .orderBy('timestamp', descending: true) // REMOVED TO FIX INDEX ERROR
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

          final List<QueryDocumentSnapshot> orders = snapshot.data!.docs;

          // Manual Sorting to avoid Index error but keep UX
          orders.sort((a, b) {
            Timestamp? tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            Timestamp? tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(18, 'All Managed Orders', fontWeight: FontWeight.bold),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 40,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                      columns: [
                        DataColumn(label: customText(14, 'Image', fontWeight: FontWeight.bold)),
                        DataColumn(label: customText(14, 'Order ID', fontWeight: FontWeight.bold)),
                        DataColumn(label: customText(14, 'Product', fontWeight: FontWeight.bold)),
                        DataColumn(label: customText(14, 'Qty', fontWeight: FontWeight.bold)),
                        DataColumn(label: customText(14, 'Amount', fontWeight: FontWeight.bold)),
                        DataColumn(label: customText(14, 'Status', fontWeight: FontWeight.bold)),
                        DataColumn(label: customText(14, 'Action', fontWeight: FontWeight.bold)),
                      ],
                      rows: orders.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final orderId = doc.id;
                        final status = data['status'] ?? 'Placed';
                        final amount = data['totalAmount']?.toString() ?? '0';

                        return DataRow(
                          cells: [
                            DataCell(
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: data['productImage'] != null && data['productImage'].toString().isNotEmpty
                                    ? Image.network(data['productImage'], width: 40, height: 40, fit: BoxFit.cover)
                                    : Container(width: 40, height: 40, color: Colors.grey.shade200, child: const Icon(Icons.image, size: 20)),
                              ),
                            ),
                            DataCell(customText(14, orderId.substring(0, 8).toUpperCase(), fontWeight: FontWeight.bold)),
                            DataCell(SizedBox(width: 150, child: customText(14, data['productName'] ?? 'Unknown', ))),
                            DataCell(customText(14, "x${data['quantity'] ?? 1}")),
                            DataCell(customText(14, "₹$amount", fontWeight: FontWeight.bold)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: customText(12, status, webcolors: _getStatusColor(status), fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => _showUpdateStatusDialog(context, orderId, status),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF673AB7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text('Update'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Placed':
      case 'Processing':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
      case 'Return Requested':
      case 'Returned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    String orderId,
    String currentStatus,
  ) {
    String selectedStatus = currentStatus;

    // --- SMART AUTHENTIC SELLER LOGIC ---
    List<String> statuses = [
      'Placed',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];

    if (currentStatus == 'Return Requested') {
      statuses = ['Return Requested', 'Return Approved', 'Return Rejected'];
    } else if (currentStatus == 'Return Approved') {
      statuses = [
        'Return Approved',
        'Item Returned',
      ]; // Seller clicked when it arrives at warehouse
    } else if ([
      'Item Returned',
      'Refund Processed',
      'Return Rejected',
    ].contains(currentStatus)) {
      statuses = [
        currentStatus,
      ]; // LOCKED! Sellers cannot undo this phase. Admin takes over!
    }

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
                    "Manage Order Status",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (statuses.length == 1)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "This order is currently locked and awaiting Admin Financial review.",
                        style: TextStyle(color: Colors.red),
                      ),
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
                        Navigator.pop(context);
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .update({
                              'status': selectedStatus,
                              'lastUpdated': FieldValue.serverTimestamp(),
                            });
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
