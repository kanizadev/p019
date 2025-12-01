import 'package:flutter/material.dart';
import 'package:my_app/review.dart';
import 'package:my_app/theme.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Simplified for Cash on Delivery only

  @override
  void dispose() {
    super.dispose();
  }

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
                  active: true,
                  primary: primary,
                  bg: stepBg,
                ),
                const SizedBox(width: 12),
                _StepCircle(
                  label: '3',
                  active: false,
                  primary: primary,
                  bg: stepBg,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            const Text('Payment method'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.surface),
              ),
              child: const ListTile(
                leading: Icon(Icons.delivery_dining),
                title: Text('Cash on Delivery'),
                subtitle: Text('Pay when your order arrives'),
              ),
            ),

            const SizedBox(height: 16),

            // Card/PayPal removed; COD requires no additional fields
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const ReviewPage()));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primary,
                  disabledBackgroundColor:
                      AppTheme.textDark.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Review order'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
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

// Card form removed (only Cash on Delivery supported)

// Helper removed with card form

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
