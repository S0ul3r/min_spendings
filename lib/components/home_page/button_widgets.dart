import 'package:flutter/material.dart';
import 'package:min_spendings/models/expense.dart';

class BaseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const BaseButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final Function(Expense?) onPressed;
  final Expense? expense;

  const SaveButton({super.key, required this.onPressed, this.expense});

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      onPressed: () => onPressed(expense),
      text: 'Save',
      color: Colors.lightBlue.shade900,
    );
  }
}

class DeleteButton extends StatelessWidget {
  final Function(int) onPressed;
  final int id;

  const DeleteButton({super.key, required this.onPressed, required this.id});

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      onPressed: () => onPressed(id),
      text: 'Delete',
      color: Colors.red,
    );
  }
}

class CancelButton extends StatelessWidget {
  final Function() onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      onPressed: onPressed,
      text: 'Cancel',
      color: Colors.grey.shade600,
    );
  }
}