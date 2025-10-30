import 'dart:async';
import 'package:flutter/material.dart';

typedef OnSearchParametersChanged = void Function(Map<String, dynamic> params);

class SearchBarFilter extends StatefulWidget {
  final OnSearchParametersChanged onSearchChanged;
  const SearchBarFilter({super.key, required this.onSearchChanged});

  @override
  State<SearchBarFilter> createState() => _SearchBarFilterState();
}

class _SearchBarFilterState extends State<SearchBarFilter> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'updatedAt';
  bool _isDescending = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _triggerSearch() {
      widget.onSearchChanged({
        'query': _searchController.text.trim(),
        'sortBy': _sortBy,
        'isDescending': _isDescending,
      });
  } // starts fetching notes

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _triggerSearch,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _triggerSearch(),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                    _triggerSearch();
                },
              ),

            // Sort Order Toggle Button
            IconButton(
              icon: Icon(
                _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
              ),
              onPressed: () {
                setState(() {
                  _isDescending = !_isDescending;
                });
                _triggerSearch();
              },
            ),

            // Sort By Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_by_alpha),
              onSelected: (String value) {
                setState(() {
                  _sortBy = value;
                });
                _triggerSearch();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'updatedAt',
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: _sortBy == 'updatedAt'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'title',
                  child: Text(
                    'Title',
                    style: TextStyle(
                      fontWeight: _sortBy == 'title'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
