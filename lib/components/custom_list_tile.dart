import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:min_spendings/helper/helper_functions.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final String category;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const CustomListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.category,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            _buildSettingsAction(),
            _buildDeleteAction(),
          ],
        ),
        child: _buildContainer(),
      ),
    );
  }

  Widget _buildSettingsAction() {
    return SlidableAction(
      onPressed: onEditPressed,
      icon: Icons.settings,
      backgroundColor: Colors.grey.shade600,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildDeleteAction() {
    return SlidableAction(
      onPressed: onDeletePressed,
      icon: Icons.delete,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          _buildCategoryContainer(),
          _buildListTile(),
        ],
      ),
    );
  }

  Widget _buildCategoryContainer() {
    return Positioned(
      left: 130.0,
      top: 16.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: getColorFromCategory(category),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          category,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildListTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 0, right: 0),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        trailing: Text(trailing, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}