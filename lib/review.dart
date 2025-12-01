import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppTheme.primary;
    final Color stepBg = AppTheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                _StepCircle(
                  label: '1',
                  active: false,
                  primary: primary,
                  bg: stepBg,
                ),
                const SizedBox(width: 10),
                const Text('Shipping', style: TextStyle(fontSize: 18)),
                const Spacer(),
                _StepCircle(
                  label: '2',
                  active: false,
                  primary: primary,
                  bg: stepBg,
                ),
                const SizedBox(width: 12),
                _StepCircle(
                  label: '3',
                  active: true,
                  primary: primary,
                  bg: stepBg,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            Text(
              'Review your order',
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'Shipping address',
              child: const Text(
                'John Doe\n123 Main Street\nSpringfield, USA 12345',
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Payment method',
              child: const Text('Visa •••• 3456 (John Doe)'),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Items',
              child: Column(
                children: const [
                  _LineItem(name: 'Cappuccino', qty: 2, price: 8.00),
                  _LineItem(name: 'Blueberry Muffin', qty: 1, price: 4.25),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Summary',
              child: Column(
                children: const [
                  _SummaryRow(label: 'Subtotal', value: 20.25),
                  _SummaryRow(label: 'Tax (10%)', value: 2.03),
                  Divider(height: 20),
                  _SummaryRow(label: 'Total', value: 22.28, bold: true),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed!')),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Place order'),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.surface),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.name, required this.qty, required this.price});
  final String name;
  final int qty;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text('$name × $qty')),
          Text('\$${(price).toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.label,
    required this.active,
    required this.primary,
    required this.bg,
  });
  final String label;
  final bool active;
  final Color primary;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? primary : bg,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppTheme.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
