import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _totalBalance = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // TODO: Replace with database fetching logic
    // Simulated data
    setState(() {
      _totalBalance = 1200.0; // Example balance
      _transactions = [
        {'id': 1, 'title': 'Groceries', 'amount': -50.0, 'date': '2024-11-01'},
        {'id': 2, 'title': 'Salary', 'amount': 1500.0, 'date': '2024-11-01'},
      ];
    });
  }

  void _navigateToAddTransaction() async {
    final result = await Navigator.pushNamed(context, '/addTransaction');
    if (result == true) {
      _fetchData(); // Refresh data after adding a transaction
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Manager'),
      ),
      body: Column(
        children: [
          // Balance Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Divider(),
          // Transactions List
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return ListTile(
                  leading: Icon(transaction['amount'] < 0
                      ? Icons.remove_circle
                      : Icons.add_circle),
                  title: Text(transaction['title']),
                  subtitle: Text(transaction['date']),
                  trailing: Text(
                    transaction['amount'] < 0
                        ? '-\$${transaction['amount'].abs()}'
                        : '\$${transaction['amount']}',
                    style: TextStyle(
                      color: transaction['amount'] < 0
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: Icon(Icons.add),
      ),
    );
  }
}
