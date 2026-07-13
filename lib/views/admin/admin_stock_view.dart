import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../shared/widgets.dart';

class AdminStockView extends StatefulWidget {
  final bool isDark;
  const AdminStockView({super.key, required this.isDark});

  @override
  State<AdminStockView> createState() => _AdminStockViewState();
}

class _AdminStockViewState extends State<AdminStockView> {
  final Map<String, TextEditingController> _controllers = {
    'keju': TextEditingController(),
    'ori': TextEditingController(),
    'coklat': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _adjustStock(
    StockProvider provider,
    String flavor,
    int amountChange,
  ) async {
    final success = await provider.updateStock(
      flavor: flavor,
      amountChange: amountChange,
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stok ${flavor.toUpperCase()} berhasil diperbarui (${amountChange > 0 ? "+" : ""}$amountChange)',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal memperbarui stok'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _resetStock(StockProvider provider, String flavor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark
            ? AppColors.cardDark
            : AppColors.cardLight,
        title: Text(
          'Hapus Stok Pemilik?',
          style: TextStyle(
            color: widget.isDark ? AppColors.textLight : AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda sebagai PEMILIK yakin ingin mengosongkan (reset menjadi 0) seluruh stok rasa ${flavor.toUpperCase()}?',
          style: TextStyle(
            color: (widget.isDark ? AppColors.textLight : AppColors.textDark)
                .withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus Stok',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.resetStock(flavor);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stok ${flavor.toUpperCase()} berhasil dikosongkan oleh Pemilik.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _handleManualInput(
    StockProvider provider,
    String flavor,
    bool isAdd,
  ) async {
    final text = _controllers[flavor]!.text;
    if (text.isEmpty) return;

    final val = int.tryParse(text);
    if (val == null || val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah angka yang valid'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final change = isAdd ? val : -val;
    _adjustStock(provider, flavor, change);
    _controllers[flavor]!.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final textColor = widget.isDark ? AppColors.textLight : AppColors.textDark;

    final List<Map<String, dynamic>> itemsList = [
      {
        'flavor': 'keju',
        'name': 'Molen Rasa Keju',
        'color': const Color(0xFFF1C40F),
        'icon': Icons.restaurant,
      },
      {
        'flavor': 'ori',
        'name': 'Molen Rasa Ori (Original)',
        'color': const Color(0xFFE67E22),
        'icon': Icons.breakfast_dining,
      },
      {
        'flavor': 'coklat',
        'name': 'Molen Rasa Coklat',
        'color': const Color(0xFF795548),
        'icon': Icons.cookie,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kontrol Stok Pemilik',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kelola pasokan molen pusat dan tingkatkan jumlah pasokan harian.',
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                final item = itemsList[index];
                final flavor = item['flavor'] as String;
                final qty = provider.stocks[flavor] ?? 0;
                final controller = _controllers[flavor]!;

                return PremiumCard(
                  isDark: widget.isDark,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: (item['color'] as Color)
                                    .withOpacity(0.2),
                                radius: 18,
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          // Warning indicator for low stock
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: qty <= 10
                                  ? AppColors.error.withOpacity(0.15)
                                  : (item['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: qty <= 10
                                    ? AppColors.error
                                    : (item['color'] as Color).withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              qty <= 10 ? 'KRITIS: $qty pcs' : 'Stok: $qty pcs',
                              style: TextStyle(
                                color: qty <= 10
                                    ? AppColors.error
                                    : (widget.isDark
                                          ? AppColors.softButterCream
                                          : AppColors.goldenCaramel),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                foregroundColor: AppColors.error,
                              ),
                              onPressed: () =>
                                  _adjustStock(provider, flavor, -50),
                              child: const Text('-50'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                foregroundColor: AppColors.error,
                              ),
                              onPressed: () =>
                                  _adjustStock(provider, flavor, -20),
                              child: const Text('-20'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.royalHoneyGold,
                                ),
                                foregroundColor: AppColors.royalHoneyGold,
                              ),
                              onPressed: () =>
                                  _adjustStock(provider, flavor, 20),
                              child: const Text('+20'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.royalHoneyGold,
                                ),
                                foregroundColor: AppColors.royalHoneyGold,
                              ),
                              onPressed: () =>
                                  _adjustStock(provider, flavor, 50),
                              child: const Text('+50'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Manual Input controls
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: controller,
                              labelText: 'Sesuaikan Manual',
                              hintText: 'Misal: 100',
                              prefixIcon: Icons.add_business_outlined,
                              isDark: widget.isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_box),
                            color: AppColors.royalHoneyGold,
                            iconSize: 42,
                            onPressed: () =>
                                _handleManualInput(provider, flavor, true),
                            tooltip: 'Tambah stok',
                          ),
                          IconButton(
                            icon: const Icon(Icons.indeterminate_check_box),
                            color: AppColors.goldenCaramel,
                            iconSize: 42,
                            onPressed: () =>
                                _handleManualInput(provider, flavor, false),
                            tooltip: 'Kurang stok',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep),
                            color: AppColors.error,
                            iconSize: 36,
                            onPressed: () => _resetStock(provider, flavor),
                            tooltip: 'Reset stok',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
