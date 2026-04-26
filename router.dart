// lib/router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/main_app_layout.dart';
import 'screens/game_screen.dart';
import 'screens/dummy_screens.dart'; // Оставляем для задач и профиля
import 'screens/main_path_screen.dart'; // Наш путь

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Изменили стартовую страницу. Теперь приложение сразу открывает путь!
    initialLocation: '/lessons',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainAppLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/game',
            builder: (context, state) => const GameScreen(),
          ),
          GoRoute(
            path: '/lessons',
            // ВОТ ОНО! Теперь вкладка "Уроки" открывает наш зигзаг из ромбов
            builder: (context, state) => const MainPathScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksDummyScreen(),
          ),
        ],
      ),
    ],
  );
});
