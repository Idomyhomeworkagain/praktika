import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  // Оборачиваем в ProviderScope для Riverpod
  runApp(const ProviderScope(child: ChessLeadApp()));
}

class ChessLeadApp extends ConsumerWidget {
  const ChessLeadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем наш настроенный роутер
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ChessLead',
      theme: chessLeadTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
