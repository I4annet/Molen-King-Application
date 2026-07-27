import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
// import '../../providers/transaction_provider.dart';
// import '../../providers/expense_provider.dart';
// import '../../providers/stock_provider.dart';
import '../../providers/report_provider.dart';
import '../shared/widgets.dart';

class AdminDashboardView extends StatefulWidget {
  final bool isDark;
  const AdminDashboardView({super.key, required this.isDark});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String _selectedPeriod = 'weekly'; // 'daily', 'weekly', 'monthly', 'yearly'
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider = context.read<ReportProvider>();
      reportProvider.loadReportData();
    });
  }

  Widget _legend(Color color, String text, Color textColor) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    // final transactionProvider = context.watch<TransactionProvider>();
    // final expenseProvider = context.watch<ExpenseProvider>();
    // final stockProvider = context.watch<StockProvider>();
    final reportProvider = context.watch<ReportProvider>();
    final stats = reportProvider.getStatsForPeriod(_selectedPeriod);
    final chartData = reportProvider.getChartDataForPeriod(_selectedPeriod);
    final textColor = widget.isDark ? AppColors.textLight : AppColors.textDark;

    // Calculate real-time sold counts by flavor
    final soldKeju = reportProvider.getMolenSoldQuantity(
      'keju',
      _selectedPeriod,
    );
    final soldOri = reportProvider.getMolenSoldQuantity('ori', _selectedPeriod);
    final soldCoklat = reportProvider.getMolenSoldQuantity(
      'coklat',
      _selectedPeriod,
    );
    final totalSold = reportProvider.getTotalMolenSold(_selectedPeriod);

    final isChartEmpty = soldKeju == 0 && soldOri == 0 && soldCoklat == 0;

    final pieSections = isChartEmpty
        ? [
            PieChartSectionData(
              value: 1.0,
              title: '0',
              color: Colors.grey.withOpacity(0.3),
              radius: 40,
              titleStyle: TextStyle(
                color: textColor.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          ]
        : [
            PieChartSectionData(
              value: soldKeju.toDouble(),
              title: '$soldKeju',
              color: const Color(0xFFF1C40F),
              radius: 40,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            PieChartSectionData(
              value: soldOri.toDouble(),
              title: '$soldOri',
              color: const Color(0xFFE67E22),
              radius: 40,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            PieChartSectionData(
              value: soldCoklat.toDouble(),
              title: '$soldCoklat',
              color: const Color(0xFF795548),
              radius: 40,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ];

    return RefreshIndicator(
      onRefresh: () async {
        await reportProvider.loadReportData();
      },
      color: AppColors.royalHoneyGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Penjualan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ringkasan data transaksi real-time.',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                // Period Selector Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
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
                      value: _selectedPeriod,
                      dropdownColor: widget.isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('Hari Ini'),
                        ),
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
                            _selectedPeriod = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Real-time Sold breakdown
            PremiumCard(
              isDark: widget.isDark,
              height: 280,
              child: Column(
                children: [
                  Text(
                    "Komposisi Penjualan Molen",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 35,
                        sectionsSpace: 3,
                        sections: pieSections,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _legend(const Color(0xFFF1C40F), "Keju", textColor),
                      _legend(const Color(0xFFE67E22), "Ori", textColor),
                      _legend(const Color(0xFF795548), "Coklat", textColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Overview metrics cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Pendapatan Kotor',
                    currencyFormatter.format(stats['revenue']),
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Pengeluaran',
                    currencyFormatter.format(stats['expenses']),
                    Icons.trending_down,
                    AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              'Pendapatan Bersih (Net Profit)',
              currencyFormatter.format(stats['profit']),
              Icons.account_balance_wallet,
              AppColors.royalHoneyGold,
              isFullWidth: true,
            ),
            const SizedBox(height: 20),

            // CHART GRAPH CARD
            Text(
              'Grafik Pertumbuhan Pendapatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            PremiumCard(
              isDark: widget.isDark,
              height: 240,
              child: chartData.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada data pendapatan untuk periode ini.',
                        style: TextStyle(color: textColor.withOpacity(0.5)),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            chartData
                                .map((e) => e.value)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,

                        borderData: FlBorderData(show: false),

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),

                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();

                                if (index >= chartData.length) {
                                  return const SizedBox();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    chartData[index].key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textColor.withOpacity(.7),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        barGroups: List.generate(chartData.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: chartData[index].value,
                                width: 20,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.goldenCaramel,
                                    AppColors.royalHoneyGold,
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Flavor Sold Indicator
  Widget _buildFlavorSoldStat(String name, int qty, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          child: Icon(
            name == 'Keju'
                ? Icons.restaurant
                : name == 'Ori'
                ? Icons.breakfast_dining
                : Icons.cookie,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: widget.isDark
                ? AppColors.textLight.withOpacity(0.7)
                : AppColors.textDark.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$qty pcs',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper Widget: Metric Card
  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    final textColor = widget.isDark ? AppColors.textLight : AppColors.textDark;

    return PremiumCard(
      isDark: widget.isDark,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isFullWidth ? 18 : 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
