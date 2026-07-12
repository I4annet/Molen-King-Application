import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state_provider.dart';
import '../shared/widgets.dart';

class CashierExpenseView extends StatefulWidget {
  final bool isDark;
  const CashierExpenseView({super.key, required this.isDark});

  @override
  State<CashierExpenseView> createState() => _CashierExpenseViewState();
}

class _CashierExpenseViewState extends State<CashierExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveExpense(AppStateProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal pengeluaran harus diisi angka valid!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await provider.addExpense(
      amount,
      _commentController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengeluaran berhasil dicatat!'),
            backgroundColor: AppColors.success,
          ),
        );
        _amountController.clear();
        _commentController.clear();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Gagal menyimpan pengeluaran',
            ),
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

    // Filter expenses logged by this user (to keep it clean)
    final myExpenses = provider.expenses
        .where((e) => e.cashierId == provider.currentUser?.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Catat Pengeluaran Operasional',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan nominal dan beri keterangan/komentar untuk pengeluaran toko.',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),

            PremiumCard(
              isDark: widget.isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PremiumTextField(
                    controller: _amountController,
                    labelText: 'Nominal Pengeluaran (Rupiah)',
                    hintText: 'Misal: 50000',
                    prefixIcon: Icons.money_off,
                    isDark: widget.isDark,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Nominal harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: _commentController,
                    labelText: 'Keterangan / Komentar Pengeluaran',
                    hintText:
                        'Beli minyak goreng, isi ulang gas LPG, listrik, dll.',
                    prefixIcon: Icons.comment_outlined,
                    isDark: widget.isDark,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Keterangan wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  PremiumButton(
                    text: 'Simpan Pengeluaran',
                    isInitializing: provider.isInitializing,
                    onPressed: () => _saveExpense(provider),
                    icon: Icons.save_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pengeluaran Saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldenCaramel.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: ${myExpenses.length} transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark
                          ? AppColors.softButterCream
                          : AppColors.goldenCaramel,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Expenses list
            Expanded(
              child: myExpenses.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada riwayat pengeluaran yang dicatat oleh Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: myExpenses.length,
                      itemBuilder: (context, index) {
                        final exp = myExpenses[index];
                        return PremiumCard(
                          isDark: widget.isDark,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.2),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.error.withOpacity(
                                  0.15,
                                ),
                                child: const Icon(
                                  Icons.trending_down,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormatter.format(exp.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textColor.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "- ${currencyFormatter.format(exp.amount)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
