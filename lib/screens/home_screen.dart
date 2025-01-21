import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/finance_notifier.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime selectedMonth;
  late int firstDayOfMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    firstDayOfMonth =
        Provider.of<FinanceNotifier>(context, listen: false).firstDayOfMonth;

    // Ładujemy kategorie (w BLoC) dla wybranego zakresu
    _loadCategoriesForSelectedMonth();
  }

  List<DateTime> _getPreviousMonths(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
          (index) => DateTime(now.year, now.month - index, 1),
    );
  }

  void _loadCategoriesForSelectedMonth() {
    final dateRange = _getCustomMonthRange(selectedMonth, firstDayOfMonth);
    context.read<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
  }

  // Wylicza np. "10 stycznia 2024 – 9 lutego 2024" itd.
  DateTimeRange _getCustomMonthRange(DateTime month, int firstDay) {
    final start = DateTime(month.year, month.month, firstDay);
    final nextMonth = DateTime(month.year, month.month + 1, firstDay);
    final end = nextMonth.subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    final months = _getPreviousMonths(12);

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<DateTime>(
          value: selectedMonth,
          icon: const Icon(Icons.arrow_drop_down),
          items: months.map((month) {
            final formattedMonth = DateFormat.yMMMM('pl_PL').format(month);
            return DropdownMenuItem<DateTime>(
              value: month,
              child: Text(formattedMonth),
            );
          }).toList(),
          onChanged: (newMonth) {
            if (newMonth != null) {
              setState(() {
                selectedMonth = newMonth;
              });
              _loadCategoriesForSelectedMonth();
            }
          },
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesForMonthLoaded) {
            // Mamy gotowe listy, łącznie z sumami
            final incomeCategories = state.incomeCategories;
            final expenseCategories = state.expenseCategories;

            // Zero obliczeń w UI – BLoC dał nam gotowe sumy:
            final totalIncomes = state.totalIncomes;
            final totalExpenses = state.totalExpenses;
            final budgetIncomes = state.budgetIncomes;
            final budgetExpenses = state.budgetExpenses;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (incomeCategories.isNotEmpty)
                        _buildChartSection(
                          title: AppLocalizations.of(context)!.incomes,
                          categories: incomeCategories,
                          totalSpent: totalIncomes,
                          totalBudget: budgetIncomes,
                        ),
                      if (expenseCategories.isNotEmpty)
                        _buildChartSection(
                          title: AppLocalizations.of(context)!.expenses,
                          categories: expenseCategories,
                          totalSpent: totalExpenses,
                          totalBudget: budgetExpenses,
                        ),
                      if (incomeCategories.isEmpty && expenseCategories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)!.noChartsToDisplay,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      generateMonthlyReport(
                        context: context,
                        selectedMonth: selectedMonth,
                        incomeCategories: incomeCategories,
                        expenseCategories: expenseCategories,
                        totalIncomes: totalIncomes,
                        totalExpenses: totalExpenses,
                      );
                    },
                    child: const Icon(Icons.picture_as_pdf),
                  ),
                ),
              ],
            );
          } else if (state is CategoryError) {
            return Center(child: Text(state.message));
          } else {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noChartsToDisplay,
              ),
            );
          }
        },
      ),
    );
  }

  /// Sekcja wykresu / podsumowania dla Incomes / Expenses
  /// ŻADNYCH obliczeń – wszystko gotowe w parametrach
  Widget _buildChartSection({
    required String title,
    required List<Category> categories,
    required double totalSpent,
    required double totalBudget,
  }) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context)!.noChartsToDisplay,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildChartTitle(AppLocalizations.of(context)!.budgetDistribution),

        // Wykres udziału w budżecie
        _buildBudgetPieChart(categories, totalBudget),

        // Legenda do budżetu
        _buildLegend(categories, isBudget: true),

        const SizedBox(height: 16),
        _buildChartTitle(AppLocalizations.of(context)!.budgetUsage),

        // Wykres zużycia (spent / budget)
        _buildUsagePieChart(categories),

        // Legenda do zużycia
        _buildLegend(categories, isBudget: false),

        // Tekst: "Razem X/Y"
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${AppLocalizations.of(context)!.total} $title: '
                '${totalSpent.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)} '
                '(${(totalSpent / (totalBudget == 0 ? 1 : totalBudget) * 100).toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Wykres kołowy - rozłożenie budżetu między kategorie
  Widget _buildBudgetPieChart(List<Category> categories, double totalBudget) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            final catBudget = cat.budgetLimit ?? 0;
            final budgetShare =
                (catBudget / (totalBudget == 0 ? 1 : totalBudget)) * 100;

            return PieChartSectionData(
              value: budgetShare,
              title: "${cat.name}\n${budgetShare.toStringAsFixed(2)}%",
              color: Colors.primaries[
              categories.indexOf(cat) % Colors.primaries.length],
              radius: 100,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  /// Wykres kołowy - zużycie budżetu w % (spent / budget)
  Widget _buildUsagePieChart(List<Category> categories) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            // BLoC wypełnił monthlySpent, mamy np. monthlySpent[0].spentAmount
            final spent = cat.monthlySpent.isNotEmpty
                ? cat.monthlySpent.first.spentAmount
                : 0.0;

            final budget = cat.budgetLimit ?? 0;
            final usagePercentage = (spent / (budget == 0 ? 1 : budget)) * 100;

            return PieChartSectionData(
              value: usagePercentage,
              title: "${cat.name}\n${usagePercentage.toStringAsFixed(2)}%",
              color: Colors.primaries[
              categories.indexOf(cat) % Colors.primaries.length],
              radius: 100,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  /// Legenda do wykresu
  Widget _buildLegend(List<Category> categories, {required bool isBudget}) {
    return Consumer<CurrencyNotifier>(
      builder: (context, currencyNotifier, child) {
        final currency = currencyNotifier.currency;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              final color = Colors.primaries[
              categories.indexOf(cat) % Colors.primaries.length];

              if (isBudget) {
                final budget = cat.budgetLimit ?? 0;
                final value = '${currency.isLeftSigned ? currency.sign : ""}'
                    '${budget.toStringAsFixed(2)}'
                    '${!currency.isLeftSigned ? ' ${currency.sign}' : ""}';
                return _buildLegendRow(color, cat.name, value);
              } else {
                final spent = cat.monthlySpent.isNotEmpty
                    ? cat.monthlySpent.first.spentAmount
                    : 0.0;
                final budget = cat.budgetLimit ?? 1;
                final usagePct = (spent / budget) * 100;
                final value = '${usagePct.toStringAsFixed(1)}%';
                return _buildLegendRow(color, cat.name, value);
              }
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLegendRow(Color color, String categoryName, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$categoryName: $value',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  /// Generowanie raportu PDF
  Future<void> generateMonthlyReport({
    required BuildContext context,
    required DateTime selectedMonth,
    required List<Category> incomeCategories,
    required List<Category> expenseCategories,
    required double totalIncomes,
    required double totalExpenses,
  }) async {
    final pdf = pw.Document();
    final currency =
        Provider.of<CurrencyNotifier>(context, listen: false).currency;

    final incomeChartImage = await _generateChartImage(
      context,
      _buildPieChart(incomeCategories, 'Income'),
    );
    final expenseChartImage = await _generateChartImage(
      context,
      _buildPieChart(expenseCategories, 'Expense'),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => [
          pw.Text(
            '${AppLocalizations.of(context)!.monthlyReportTitle} - '
                '${DateFormat.yMMMM(AppLocalizations.of(context)!.localeName).format(selectedMonth)}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            '${AppLocalizations.of(context)!.totalIncome}: '
                '${totalIncomes.toStringAsFixed(2)} ${currency.sign}',
          ),
          pw.Text(
            '${AppLocalizations.of(context)!.totalExpenses}: '
                '${totalExpenses.toStringAsFixed(2)} ${currency.sign}',
          ),
          pw.SizedBox(height: 20),
          pw.Text(AppLocalizations.of(context)!.incomeDistribution),
          pw.SizedBox(height: 10),
          if (incomeChartImage != null)
            pw.Image(pw.MemoryImage(incomeChartImage), height: 200),
          pw.SizedBox(height: 20),
          pw.Text(AppLocalizations.of(context)!.expenseDistribution),
          pw.SizedBox(height: 10),
          if (expenseChartImage != null)
            pw.Image(pw.MemoryImage(expenseChartImage), height: 200),
          pw.SizedBox(height: 20),
          pw.Text(AppLocalizations.of(context)!.transactionDetails),
          _buildTransactionTable(incomeCategories, expenseCategories),
        ],
      ),
    );

    final output = await pdf.save();
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/Monthly_Report.pdf');
    await file.writeAsBytes(output);
    await Share.shareXFiles([XFile(file.path)], text: 'Monthly Report');
  }

  Widget _buildPieChart(List<Category> categories, String title) {
    final total = categories.fold<double>(
      0.0,
          (sum, cat) => sum + (cat.monthlySpent.isNotEmpty
          ? cat.monthlySpent.first.spentAmount
          : 0.0),
    );

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            final catSpent = cat.monthlySpent.isNotEmpty
                ? cat.monthlySpent.first.spentAmount
                : 0.0;
            final value = catSpent / (total == 0 ? 1 : total);
            return PieChartSectionData(
              value: value,
              title: '${(value * 100).toStringAsFixed(1)}%',
              color: Colors.primaries[
              categories.indexOf(cat) % Colors.primaries.length],
              radius: 100,
            );
          }).toList(),
        ),
      ),
    );
  }

  pw.Widget _buildTransactionTable(
      List<Category> incomeCategories,
      List<Category> expenseCategories,
      ) {
    final data = <pw.TableRow>[
      pw.TableRow(
        children: [
          pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Spent Amount',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
      ...incomeCategories.map(
            (cat) => pw.TableRow(
          children: [
            pw.Text(cat.name),
            pw.Text(
              cat.monthlySpent.isNotEmpty
                  ? cat.monthlySpent.first.spentAmount.toStringAsFixed(2)
                  : "0.00",
            ),
          ],
        ),
      ),
      ...expenseCategories.map(
            (cat) => pw.TableRow(
          children: [
            pw.Text(cat.name),
            pw.Text(
              cat.monthlySpent.isNotEmpty
                  ? cat.monthlySpent.first.spentAmount.toStringAsFixed(2)
                  : "0.00",
            ),
          ],
        ),
      ),
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      children: data,
    );
  }

  Future<Uint8List?> _generateChartImage(
      BuildContext context, Widget chart) async {
    // W praktyce musisz użyć RepaintBoundary z jakimś GlobalKey,
    // to tylko przykład.
    return null;
  }
}
