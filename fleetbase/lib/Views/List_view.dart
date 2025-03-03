// list_items_page.dart
import 'package:flutter/material.dart';
import '../Model/orderList_model.dart'; // Import your model classes

class ListItemsPage extends StatelessWidget {
  final OrderDelivery orderDelivery;

  const ListItemsPage({Key? key, required this.orderDelivery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderDelivery.orderDetails.id}'),
      ),
      body: ListView.builder(
        itemCount: orderDelivery.productMap.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header section with order summary
            return _buildOrderHeader(context);
          }
          final productIndex = index - 1;
          final product = orderDelivery.productMap[productIndex];
          return _buildProductItem(context, product);
        },
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${orderDelivery.clientDetails.companyName}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Contact: ${orderDelivery.clientDetails.contactPerson}'),
            Text('Phone: ${orderDelivery.clientDetails.phone}'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: Theme.of(context).textTheme.titleMedium),
                Text('\$${orderDelivery.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status: ${orderDelivery.orderDetails.status}',
                style: TextStyle(
                  color: _statusColor(orderDelivery.orderDetails.status),
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, ProductMap product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.inventory, color: Colors.blue),
        title: Text(product.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${product.quantity}'),
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Text('\$${(product.price * product.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}