import 'package:flutter/material.dart';
import 'package:split_wise/receipt-view-model.dart';
import 'package:split_wise/receipt-model.dart';
import 'package:flutter/cupertino.dart';

final receiptModel = ReceiptModel();
final receiptViewModel = ReceiptViewModel(ReceiptModel());


class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key,required this.items, required this.people});

  final List<Map<String,String>> items;
  final List<String> people;

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      SingleChildScrollView (
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              Container(
              height: 50, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.white, // Panel color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30), // Adjust curve radius as needed
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  'Cost Splitter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
              ItemTable(items: widget.items, people: widget.people),
              Padding(padding: EdgeInsets.all(16.0)),
            ],               
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class CheckboxRow extends StatefulWidget {
  final List<String> people;
  final Function(List<String>) onSelectedChanged;

  CheckboxRow({required this.people, required this.onSelectedChanged});

  @override
  _CheckboxRowState createState() => _CheckboxRowState();
}

class _CheckboxRowState extends State<CheckboxRow> {
  final Map<String, bool> _checkboxValues = {};
  @override
  void initState() {
    super.initState();
    // Initialize the checkbox values map
    widget.people.forEach((person) {
      _checkboxValues[person] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> people = widget.people;
    return Row(
      children: people.map((person) {
        return Expanded(
          child: CheckboxListTile(
            title: Text(person.substring(0,1)),
            value: _checkboxValues[person],
            onChanged: (bool? value) {
              setState(() {
                _checkboxValues[person] = value ?? false;
                // Notify parent of the change
              widget.onSelectedChanged(_getSelectedPeople());
              });
            },
          ),
        );
      }).toList(),
    );
  }

  List<String> _getSelectedPeople() {
    return _checkboxValues.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}

class ItemTable extends StatefulWidget {
  @override

  final List<String> people;
  final List<Map<String,String>> items;

  ItemTable({required this.people, required this.items});
  _ItemTableState createState() => _ItemTableState();

}

class _ItemTableState extends State<ItemTable> {

  final Map<int, List<String>> selectedPeoplePerRow = {};
  String dropdownValue = "";

  void _onSelectedChanged(int rowIndex, List<String> selectedPeople) {
    setState(() {
      selectedPeoplePerRow[rowIndex] = selectedPeople;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> people = widget.people;
    Map<String, dynamic> ans = _getPrices();
    print(people);
      return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Item', style: CupertinoTheme.of(context).textTheme.actionTextStyle)),
              DataColumn(label: Text('Price', style: CupertinoTheme.of(context).textTheme.actionTextStyle)),
              DataColumn(label: Text('People', style: CupertinoTheme.of(context).textTheme.actionTextStyle)),
            ],
            rows: widget.items.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(item['name'] ?? '', style: CupertinoTheme.of(context).textTheme.actionTextStyle)),
                  DataCell(Text(item['price'] ?? '', style: CupertinoTheme.of(context).textTheme.actionTextStyle)),
                  DataCell(CheckboxRow( 
                    people: people,
                    onSelectedChanged: (selectedPeople) =>
                      _onSelectedChanged(index, selectedPeople),)),
                ],
              );
            }).toList(),
          ),
        ),
       Table(
        border: TableBorder.all(),
        children: [TableRow(
          children: people.map((cell) {
          return TableCell(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(ans[cell].toStringAsFixed(2), style: CupertinoTheme.of(context).textTheme.actionTextStyle),
              ),
          );
            }).toList(), 
          )]
        ),
      ],
    );
      
  }

  String _calculateShare(int rowIndex, String? price) {
    List<String>? selectedPeople = selectedPeoplePerRow[rowIndex];
    double priceValue = double.tryParse(price ?? '0') ?? 0.0;

    if (selectedPeople != null && selectedPeople.isNotEmpty && priceValue > 0) {
      double share = priceValue / selectedPeople.length;
      return share.toStringAsFixed(2);
    }

    return '0.00';
  }

  Map<String, double> _getPrices() {
    Map<String, double> ans = {};
    widget.people.forEach((person) { ans[person] = 0;});
    for (var rowIndex = 0; rowIndex < widget.items.length; rowIndex++) {
      var price = widget.items[rowIndex]['price'];
      List<String>? selectedPeople = selectedPeoplePerRow[rowIndex];
      double priceValue = double.tryParse(price ?? '0') ?? 0.0;

      if (selectedPeople != null && selectedPeople.isNotEmpty && priceValue > 0) {
        double share = priceValue / selectedPeople.length;
        selectedPeople.forEach((person) { ans[person] = ans[person]! + share;});
      }
    }
    return ans;
  }
}
