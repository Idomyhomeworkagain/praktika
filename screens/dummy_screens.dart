// lib/screens/dummy_screens.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme.dart';
import '../providers/api_provider.dart';
import 'task_solving_screen.dart';

class TasksDummyScreen extends ConsumerWidget {
  const TasksDummyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: clBackground,
      body: tasksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: clPrimaryMain),
        ),
        error: (e, s) => Center(child: Text("Ошибка загрузки задач: $e")),
        data: (allTasks) {
          // БЕРЕМ ТОЛЬКО ЗАДАЧИ
          final puzzles = allTasks.where((t) => t['type'] == 'puzzle').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🧩 Задачи на тактику",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                    color: clPrimaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Решай задачи, чтобы повысить свой рейтинг",
                  style: TextStyle(fontSize: 16, color: clGrayText),
                ),
                const SizedBox(height: 32),

                if (puzzles.isEmpty)
                  const Text(
                    "Пока нет доступных задач",
                    style: TextStyle(fontSize: 18),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: puzzles.length,
                    itemBuilder: (context, index) {
                      final item = puzzles[index];
                      return _buildTaskCard(
                        context,
                        title: item['title'] ?? "Задача",
                        description: item['description'] ?? "",
                        icon: FontAwesomeIcons.chessBoard,
                        fen: item['fen'],
                        solution: item['solution'] ?? [],
                        type: 'puzzle',
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
    required String title,
    required String description,
    required dynamic icon,
    required String fen,
    required List<dynamic> solution,
    required String type,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => TaskSolvingScreen(
            title: title,
            description: description,
            fen: fen,
            solution: solution,
            type: type,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FaIcon(icon, color: clPrimaryMain, size: 28),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: clDarkText),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: clPrimaryMain.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Решить",
                  style: TextStyle(
                    color: clPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
