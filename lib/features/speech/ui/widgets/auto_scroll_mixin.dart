import 'package:flutter/material.dart';

mixin AutoScrollMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool _isUserScrolling = false;
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.isScrollingNotifier.value) {
      _isUserScrolling = true;
    }

    // Check if we're at the bottom
    _isAtBottom = scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 50; // 50 pixels threshold
  }

  void scrollToBottom() {
    if (!_isUserScrolling || _isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void resetScrollState() {
    _isUserScrolling = false;
  }
}
