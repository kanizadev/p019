import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_app/models/order.dart';
import 'package:my_app/models/coffee_item.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final Color primary;
  final List<CoffeeItem> allItems;

  const OrderTile({
    super.key,
    required this.order,
    required this.primary,
    required this.allItems,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        order.id,
        style: TextStyle(fontWeight: FontWeight.bold, color: primary),
      ),
      subtitle: Text(order.dateText),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${order.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: primary),
          ),
          Text(
            order.status,
            style: TextStyle(
              color: order.status == 'Delivered'
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Items Ordered:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                final coffeeItem = allItems.firstWhere(
                  (coffee) => coffee.name == item.name,
                  orElse: () => CoffeeItem(
                    name: item.name,
                    subtitle: '',
                    price: '\$${item.price.toStringAsFixed(2)}',
                    imageUrl: '',
                    category: '',
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: coffeeItem.imageUrl.isEmpty
                            ? Container(
                                width: 40,
                                height: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.coffee,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: coffeeItem.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 40,
                                  height: 40,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 40,
                                  height: 40,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.coffee,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              coffeeItem.subtitle,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Qty: ${item.quantity}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
