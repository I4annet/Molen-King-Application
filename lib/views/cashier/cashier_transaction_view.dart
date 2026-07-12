import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state_provider.dart';
import '../../models/transaction_model.dart';
import '../shared/widgets.dart';

class CashierTransactionView extends StatefulWidget {
  final bool isDark;
  const CashierTransactionView({super.key, required this.isDark});

  @override
  State<CashierTransactionView> createState() => _CashierTransactionViewState();
}

class _CashierTransactionViewState extends State<CashierTransactionView> {
  final Map<String, int> _cart = {'keju': 0, 'ori': 0, 'coklat': 0};
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _increment(String flavor, int maxQty) {
    if ((_cart[flavor] ?? 0) < maxQty) {
      setState(() {
        _cart[flavor] = (_cart[flavor] ?? 0) + 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah melebihi stok yang tersedia ($maxQty)'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _decrement(String flavor) {
    if ((_cart[flavor] ?? 0) > 0) {
      setState(() {
        _cart[flavor] = (_cart[flavor] ?? 0) - 1;
      });
    }
  }

  double _calculateTotal(AppStateProvider provider) {
    double total = 0;
    _cart.forEach((flavor, qty) {
      total += (provider.molenPrices[flavor] ?? 0.0) * qty;
    });
    return total;
  }

  bool _isCartEmpty() {
    return _cart.values.every((qty) => qty == 0);
  }

  void _checkout(AppStateProvider provider) async {
    if (_isCartEmpty()) return;

    final List<TransactionItem> items = [];
    _cart.forEach((flavor, qty) {
      if (qty > 0) {
        items.add(
          TransactionItem(
            flavor: flavor,
            quantity: qty,
            price: provider.molenPrices[flavor] ?? 0.0,
          ),
        );
      }
    });

    final success = await provider.createTransaction(items);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi Berhasil Disimpan!'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _cart.updateAll((key, value) => 0);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Transaksi Gagal'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final textColor = widget.isDark ? AppColors.textLight : AppColors.textDark;
    final total = _calculateTotal(provider);

    final List<Map<String, dynamic>> itemsList = [
      {
        'flavor': 'keju',
        'name': 'Molen Rasa Keju',
        'icon': Icons.restaurant,
        'image_color': const Color(0xFFF1C40F),
      },
      {
        'flavor': 'ori',
        'name': 'Molen Rasa Ori (Original)',
        'icon': Icons.breakfast_dining,
        'image_color': const Color(0xFFE67E22),
      },
      {
        'flavor': 'coklat',
        'name': 'Molen Rasa Coklat',
        'icon': Icons.cookie,
        'image_color': const Color(0xFF795548),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transaksi Penjualan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih rasa molen dan tentukan kuantitas penjualan.',
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                final item = itemsList[index];
                final flavor = item['flavor'] as String;
                final price = provider.molenPrices[flavor] ?? 0.0;
                final stock = provider.stocks[flavor] ?? 0;
                final cartQty = _cart[flavor] ?? 0;

                return PremiumCard(
                  isDark: widget.isDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: (item['image_color'] as Color).withOpacity(
                            0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item['image_color'] as Color,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 32,
                          color: item['image_color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(price),
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.isDark
                                    ? AppColors.royalHoneyGold
                                    : AppColors.goldenCaramel,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: stock > 10
                                    ? AppColors.sageMint.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Stok: $stock pcs',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: stock > 10
                                      ? (widget.isDark
                                            ? AppColors.sageMint
                                            : AppColors.goldenCaramel)
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Counter Controls
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: cartQty > 0
                                ? AppColors.goldenCaramel
                                : textColor.withOpacity(0.3),
                            onPressed: () => _decrement(flavor),
                          ),
                          Text(
                            '$cartQty',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: stock > 0
                                ? AppColors.royalHoneyGold
                                : textColor.withOpacity(0.3),
                            onPressed: () => _increment(flavor, stock),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Total & Checkout Section
          PremiumCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      currencyFormatter.format(total),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? AppColors.softButterCream
                            : AppColors.goldenCaramel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PremiumButton(
                  text: 'Selesaikan Transaksi',
                  isInitializing: provider.isInitializing,
                  onPressed: _isCartEmpty() ? () {} : () => _checkout(provider),
                  icon: Icons.shopping_cart_checkout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
