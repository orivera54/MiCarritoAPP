import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

class DebouncedSearchController {
  final Debouncer _debouncer;
  final Function(String) onSearch;
  String _lastQuery = '';

  DebouncedSearchController({
    required this.onSearch,
    int debounceTime = 500,
  }) : _debouncer = Debouncer(milliseconds: debounceTime);

  void search(String query) {
    if (query == _lastQuery) return;
    
    _lastQuery = query;
    _debouncer.run(() {
      onSearch(query);
    });
  }

  void dispose() {
    _debouncer.cancel();
  }
}