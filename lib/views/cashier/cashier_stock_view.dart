import 'package:flutter/material.dart';
import 'package:molen_king_application/providers/stock_provider.dart';
import 'package:provider/provider.dart';
// import '../../providers/app_state_provider.dart';
import '../shared/widgets.dart';

class CashierStockView extends StatefulWidget {
  final bool isDark;
  const CashierStockView({super.key, required this.isDark});

  @override
  State<CashierStockView> createState() => _CashierStockViewState();
}

class _CashierStockViewState extends State<CashierStockView> {
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
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark
            ? AppColors.cardDark
            : AppColors.cardLight,
        title: Text(
          'Hapus Stok?',
          style: TextStyle(
            color: widget.isDark ? AppColors.textLight : AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus (reset menjadi 0) semua stok Rasa ${flavor.toUpperCase()}?',
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
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stok ${flavor.toUpperCase()} telah di-reset menjadi 0',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
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
        'name': 'Molen Rasa Ori',
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
            'Kelola Stok Toko',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Menambah, mengurangi, atau menghapus stok molen secara manual.',
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
                      // Header Row
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
                          // Stock Indicator Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (item['color'] as Color).withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              'Stok: $qty pcs',
                              style: TextStyle(
                                color: widget.isDark
                                    ? AppColors.softButterCream
                                    : AppColors.goldenCaramel,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Adjustments Buttons
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
                                  _adjustStock(provider, flavor, -10),
                              child: const Text('-10'),
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
                                  _adjustStock(provider, flavor, -5),
                              child: const Text('-5'),
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
                                  _adjustStock(provider, flavor, 5),
                              child: const Text('+5'),
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
                                  _adjustStock(provider, flavor, 10),
                              child: const Text('+10'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Manual Input & Delete Block
                      Row(
                        children: [
                          Expanded(
                            child: PremiumTextField(
                              controller: controller,
                              labelText: 'Jumlah Kustom',
                              hintText: 'Misal: 25',
                              prefixIcon: Icons.edit_note,
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
                            tooltip: 'Tambah manual',
                          ),
                          IconButton(
                            icon: const Icon(Icons.indeterminate_check_box),
                            color: AppColors.goldenCaramel,
                            iconSize: 42,
                            onPressed: () =>
                                _handleManualInput(provider, flavor, false),
                            tooltip: 'Kurang manual',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep),
                            color: AppColors.error,
                            iconSize: 36,
                            onPressed: () => _resetStock(provider, flavor),
                            tooltip: 'Kosongkan stok',
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
