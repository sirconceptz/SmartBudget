import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

  /// Tutaj będziemy przechowywać listę *dostępnych* miesięcy,
  /// które faktycznie mają wydatki (> 0) w co najmniej jednej kategorii.
  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    // Domyślnie ustawiamy aktualny miesiąc
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    firstDayOfMonth =
        Provider.of<FinanceNotifier>(context, listen: false).firstDayOfMonth;

    _loadCategoriesForSelectedMonth();
  }

  /// Metoda używana w Twoim oryginalnym kodzie – zostaje,
  /// ale niekoniecznie musisz z niej korzystać
  List<DateTime> _getPreviousMonths(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
      (index) => DateTime(now.year, now.month - index, 1),
    );
  }

  /// NOWA METODA:
  /// Zwraca listę miesięcy (DateTime(yyyy, mm, 1)),
  /// w których łączne spentAmount > 0 w *jakiejkolwiek* kategorii
  List<DateTime> _getAvailableMonthsFromCategories(
      List<Category> incomeCategories, List<Category> expenseCategories) {
    // Zbierz wszystkie kategorie
    final allCats = [...incomeCategories, ...expenseCategories];

    // Zbierz monthKey (np. "2024-01") tylko tam, gdzie spentAmount > 0
    final monthKeys = <String>{}; // używamy Set, żeby uniknąć duplikatów

    for (final cat in allCats) {
      for (final ms in cat.monthlySpent) {
        if (ms.spentAmount > 0) {
          monthKeys.add(ms.monthKey);
        }
      }
    }

    // Parsujemy monthKey -> DateTime(yyyy, mm, 1)
    final parsedMonths = monthKeys.map((key) => _parseMonthKey(key)).toList();

    // Sortujemy np. malejąco (nowsze miesiące na górze),
    // lub rosnąco, jak wolisz
    parsedMonths.sort((a, b) => b.compareTo(a));

    return parsedMonths;
  }

  /// Pomocnicza funkcja do zamiany "YYYY-MM" na DateTime(YYYY, MM, 1)
  DateTime _parseMonthKey(String monthKey) {
    final parts = monthKey.split('-'); // ["2024", "01"]
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(y, m, 1);
  }

  /// Wywołuje event z BLoC, aby załadować kategorie w danym przedziale
  void _loadCategoriesForSelectedMonth() {
    final dateRange = _getCustomMonthRange(selectedMonth, firstDayOfMonth);
    context.read<CategoryBloc>().add(LoadCategoriesWithSpentAmounts(dateRange));
  }

  /// Wylicza np. "10 stycznia 2024 – 9 lutego 2024" itd.
  DateTimeRange _getCustomMonthRange(DateTime month, int firstDay) {
    final start = DateTime(month.year, month.month, firstDay);
    final nextMonth = DateTime(month.year, month.month + 1, firstDay);
    final end = nextMonth.subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    // final months = _getPreviousMonths(12); // STARE
    // -> teraz będziemy dynamicznie ustawiać _availableMonths w builderze

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CategoryBloc, CategoryState>(
          buildWhen: (previous, current) {
            // odśwież dropdown tylko, gdy zmienia się stan
            return true;
          },
          builder: (context, state) {
            if (state is CategoriesForMonthLoaded) {
              // 1. Oblicz listę *dostępnych* miesięcy z transakcji
              _availableMonths = _getAvailableMonthsFromCategories(
                state.incomeCategories,
                state.expenseCategories,
              );

              // 2. Jeśli nasz selectedMonth nie jest w liście _availableMonths,
              //    to można ustawić default (np. pierwszy element listy)
              if (_availableMonths.isNotEmpty &&
                  !_availableMonths.contains(selectedMonth)) {
                // Ustawiamy wybrany miesiąc na najnowszy (pierwszy w posortowanej liście)
                // lub cokolwiek innego chcesz
                selectedMonth = _availableMonths.first;
                // i od razu ładujemy kategorie?
                // _loadCategoriesForSelectedMonth();
                // Lepiej nie, bo by się zapętliło –
                // raczej user sam wybierze z dropdown
              }

              // Budujemy dropdown
              return DropdownButton<DateTime>(
                value: _availableMonths.contains(selectedMonth)
                    ? selectedMonth
                    : (_availableMonths.isNotEmpty
                        ? _availableMonths.first
                        : null),
                icon: const Icon(Icons.arrow_drop_down),
                items: _availableMonths.map((monthDate) {
                  final formattedMonth =
                      DateFormat.yMMMM('pl_PL').format(monthDate);
                  return DropdownMenuItem<DateTime>(
                    value: monthDate,
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
              );
            } else {
              // Dopóki nie mamy stanu z listą kategorii,
              // możemy np. pokazać proste Text("...")
              return Text(AppLocalizations.of(context)!.incomes);
            }
          },
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoriesForMonthLoaded) {
            final incomeCategories = state.incomeCategories;
            final expenseCategories = state.expenseCategories;

            final totalIncomes = state.totalIncomes;
            final totalExpenses = state.totalExpenses;
            final budgetIncomes = state.budgetIncomes;
            final budgetExpenses = state.budgetExpenses;

            return SingleChildScrollView(
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
        _buildBudgetPieChart(categories, totalBudget),
        _buildLegend(categories, isBudget: true),
        const SizedBox(height: 16),
        _buildChartTitle(AppLocalizations.of(context)!.budgetUsage),
        _buildUsagePieChart(categories),
        _buildLegend(categories, isBudget: false),
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
              title: "${budgetShare.toStringAsFixed(2)}%",
              color: Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length],
              radius: 60,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildUsagePieChart(List<Category> categories) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: categories.map((cat) {
            final spent = cat.monthlySpent.isNotEmpty
                ? cat.monthlySpent.first.spentAmount
                : 0.0;

            final budget = cat.budgetLimit ?? 0;
            final usagePercentage = (spent / (budget == 0 ? 1 : budget)) * 100;

            return PieChartSectionData(
              value: usagePercentage,
              title: "${cat.name}\n${usagePercentage.toStringAsFixed(2)}%",
              color: Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length],
              radius: 60,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildLegend(List<Category> categories, {required bool isBudget}) {
    return Consumer<CurrencyNotifier>(
      builder: (context, currencyNotifier, child) {
        final currency = currencyNotifier.currency;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              final color = Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length];

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
      (sum, cat) =>
          sum +
          (cat.monthlySpent.isNotEmpty
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
              color: Colors
                  .primaries[categories.indexOf(cat) % Colors.primaries.length],
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
          pw.Text('Category',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
    return null;
  }
}
