import 'package:flutter/material.dart';
import 'package:min_spendings/models/expense.dart';

class SaveButton extends StatelessWidget {
  final Function(Expense?) onPressed;
  final Expense? expense;

  const SaveButton({super.key, required this.onPressed, this.expense});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(expense),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: const Text('Save',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final Function(int) onPressed;
  final int id;

  const DeleteButton({super.key, required this.onPressed, required this.id});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: const Text('Delete',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final Function() onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: const Text('Cancel',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
