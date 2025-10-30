import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final Function(int) onPageChanged;
  final Function(int) onPageSizeChanged;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / pageSize).ceil().clamp(1, 9999);
    // clamp: at least 1 page to avoid division by zero

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Page Size Dropdown ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Số lượng: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: pageSize,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      onPageSizeChanged(newValue);
                    }
                  },
                  // Define the available page sizes.
                  items: <int>[10, 20, 50, 100].map<DropdownMenuItem<int>>((
                    int value,
                  ) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            // --- Page Navigation ---
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  tooltip: 'First Page',
                  // Disable if on the first page.
                  onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous Page',
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                Text('$currentPage / $totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next Page',
                  // Disable if on the last page.
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  tooltip: 'Last Page',
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(totalPages)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
