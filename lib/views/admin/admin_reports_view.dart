import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import '../../providers/app_state_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/expense_model.dart';
import '../shared/widgets.dart';

class AdminReportsView extends StatefulWidget {
  final bool isDark;
  const AdminReportsView({super.key, required this.isDark});

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReportFilter =
      'weekly'; // 'daily', 'weekly', 'monthly', 'yearly'
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filter lists based on the selected time frame
  List<TransactionModel> _filterTransactions(List<TransactionModel> txs) {
    final now = DateTime.now();
    DateTime start;
    switch (_selectedReportFilter) {
      case 'daily':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'monthly':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }
    return txs.where((t) => t.createdAt.isAfter(start)).toList();
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> exps) {
    final now = DateTime.now();
    DateTime start;
    switch (_selectedReportFilter) {
      case 'daily':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'monthly':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }
    return exps.where((e) => e.createdAt.isAfter(start)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    final textColor = widget.isDark ? AppColors.textLight : AppColors.textDark;

    final filteredTxs = _filterTransactions(provider.transactions);
    final filteredExps = _filterExpenses(provider.expenses);

    double totalSales = filteredTxs.fold<double>(
      0,
      (sum, t) => sum + t.totalAmount,
    );
    double totalExpenses = filteredExps.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    double netProfit = totalSales - totalExpenses;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riwayat penjualan & pengeluaran operasional.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              // Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isDark
                        ? AppColors.royalHoneyGold.withOpacity(0.3)
                        : AppColors.sageMint,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedReportFilter,
                    dropdownColor: widget.isDark
                        ? AppColors.cardDark
                        : AppColors.cardLight,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Hari Ini')),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text('Minggu Ini'),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Bulan Ini'),
                      ),
                      DropdownMenuItem(
                        value: 'yearly',
                        child: Text('Tahun Ini'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedReportFilter = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Period Summary Panel
          PremiumCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '📊 Ringkasan Keuangan Periode Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Penjualan:',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(totalSales),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pengeluaran:',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "- ${currencyFormatter.format(totalExpenses)}",
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: AppColors.sageMint,
                  thickness: 0.5,
                  height: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Laba Bersih:',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(netProfit),
                      style: TextStyle(
                        color: netProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.royalHoneyGold,
            unselectedLabelColor: textColor.withOpacity(0.5),
            indicatorColor: AppColors.royalHoneyGold,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Penjualan (Molen)'),
              Tab(text: 'Pengeluaran (Operasional)'),
            ],
          ),
          const SizedBox(height: 12),

          // Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TRANSACTION TAB
                filteredTxs.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada transaksi penjualan di periode ini.',
                          style: TextStyle(color: textColor.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTxs.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTxs[index];
                          return PremiumCard(
                            isDark: widget.isDark,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Oleh: ${tx.cashierName}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          dateFormatter.format(tx.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textColor.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      currencyFormatter.format(tx.totalAmount),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: widget.isDark
                                            ? AppColors.softButterCream
                                            : AppColors.goldenCaramel,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(
                                  color: AppColors.sageMint,
                                  thickness: 0.3,
                                  height: 1,
                                ),
                                const SizedBox(height: 6),
                                // Item detail text
                                Wrap(
                                  spacing: 12,
                                  children: tx.items.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.royalHoneyGold
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.flavor.toUpperCase()} x${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: widget.isDark
                                              ? AppColors.softButterCream
                                              : AppColors.goldenCaramel,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // EXPENSE TAB
                filteredExps.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada catatan pengeluaran di periode ini.',
                          style: TextStyle(color: textColor.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredExps.length,
                        itemBuilder: (context, index) {
                          final ex = filteredExps[index];
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
                                    0.1,
                                  ),
                                  radius: 18,
                                  child: const Icon(
                                    Icons.arrow_downward,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Oleh: ${ex.cashierName} • ${dateFormatter.format(ex.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textColor.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "- ${currencyFormatter.format(ex.amount)}",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
