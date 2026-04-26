// lib/screens/main_path_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/api_provider.dart';
import 'task_solving_screen.dart'; // Подключаем экран доски

class LevelData {
  final Color color;
  final String? text;
  final dynamic icon;
  const LevelData({required this.color, this.text, this.icon});
}

const List<LevelData> _pathElements = [
  LevelData(color: clBrown, text: "1"),
  LevelData(color: clBrown, text: "2"),
  LevelData(color: clPrimaryMain, text: "3"),
  LevelData(color: clPrimaryDark, icon: FontAwesomeIcons.chessPawn),
  LevelData(color: clPrimaryDark, text: "4"),
  LevelData(color: clPrimaryDark, text: "5"),
  LevelData(color: clPrimaryMain, icon: FontAwesomeIcons.chessKnight),
  LevelData(color: clPrimaryDark, text: "6"),
  LevelData(color: clPrimaryMain, text: "7"),
  LevelData(color: clPrimaryDark, text: "8"),
];

class MainPathScreen extends ConsumerWidget {
  const MainPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ЗАПРАШИВАЕМ ДАННЫЕ ИЗ БАЗЫ
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ChessGridPainter())),

          tasksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: clPrimaryMain),
            ),
            error: (e, s) => Center(
              child: Text(
                "Ошибка сети. Убедитесь, что сервер запущен.\n$e",
                textAlign: TextAlign.center,
              ),
            ),
            data: (allTasks) {
              // БЕРЕМ ТОЛЬКО УРОКИ
              final lessons = allTasks
                  .where((t) => t['type'] == 'lesson')
                  .toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 20),
                      child: Center(
                        child: Text(
                          "Путь шахматиста",
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final element = _pathElements[index];
                        // Вычисляем зигзаг
                        final double offsetX = math.sin(index * 0.8) * 100;

                        // Проверяем, есть ли реальный урок в базе для этого ромба
                        final Map<String, dynamic>? lessonData =
                            index < lessons.length ? lessons[index] : null;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(offsetX, 0),
                                // ДЕЛАЕМ РОМБ КЛИКАБЕЛЬНЫМ
                                child: GestureDetector(
                                  onTap: () {
                                    if (lessonData != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => TaskSolvingScreen(
                                            title: lessonData['title'],
                                            description:
                                                lessonData['description'],
                                            fen: lessonData['fen'],
                                            solution:
                                                lessonData['solution'] ?? [],
                                            type: 'lesson',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Этот урок еще разрабатывается!",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: PathNode(
                                    color: element.color,
                                    // Если урок есть - показываем его номер, иначе старый дизайн
                                    text: lessonData != null
                                        ? "${index + 1}"
                                        : element.text,
                                    icon: element.icon,
                                    // Визуально выделяем ромбы, к которым привязан урок
                                    isUnlocked: lessonData != null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: _pathElements.length),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PathNode extends StatelessWidget {
  final Color color;
  final String? text;
  final dynamic icon;
  final bool isUnlocked;

  const PathNode({
    super.key,
    required this.color,
    this.text,
    this.icon,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    if (icon != null) {
      contentWidget = Transform.rotate(
        angle: math.pi / 4,
        child: FaIcon(icon, color: Colors.white, size: 28),
      );
    } else {
      contentWidget = Transform.rotate(
        angle: math.pi / 4,
        child: Text(
          text ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          // Если урок привязан - он яркий, если нет - тусклый (закрыт)
          color: isUnlocked ? color : color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
            BoxShadow(
              color: Colors.white54,
              blurRadius: 10,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: Center(child: contentWidget),
      ),
    );
  }
}

class ChessGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()..color = const Color.fromARGB(255, 0, 66, 46);
    final paintGreen = Paint()..color = const Color.fromARGB(255, 4, 36, 0);
    const double squareSize = 100.0;
    for (double i = 0; i < size.width; i += squareSize) {
      for (double j = 0; j < size.height; j += squareSize) {
        if (((i / squareSize) + (j / squareSize)) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i, j, squareSize, squareSize),
            paintLight,
          );
        } else {
          canvas.drawRect(
            Rect.fromLTWH(i, j, squareSize, squareSize),
            paintGreen,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
