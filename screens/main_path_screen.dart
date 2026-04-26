// lib/screens/main_path_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme.dart';

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
  LevelData(color: clPrimaryMain, text: "9"),
  LevelData(color: clPrimaryDark, icon: FontAwesomeIcons.chessBishop),
  LevelData(color: clPrimaryDark, text: "10"),
  LevelData(color: clPrimaryMain, icon: FontAwesomeIcons.chessQueen),
  LevelData(color: clPrimaryDark, text: "11"),
];

class MainPathScreen extends StatelessWidget {
  const MainPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double tileSize = 70.0;
    const double verticalStep = tileSize * 2; // Оптимальный шаг для линии
    const double amplitude = 75.0; // Размах змейки

    const double containerWidth = 400.0;
    const double center = containerWidth / 2;

    // Вычисляем общую высоту скролла
    final double pathHeight =
        _pathElements.length * verticalStep + (tileSize * 1.5);

    // Подготавливаем точки для отрисовки соединительной линии
    final List<Offset> linePoints = List.generate(_pathElements.length, (
      index,
    ) {
      final double bottom = index * verticalStep;
      final double xOffset = math.sin(index * 0.8) * amplitude;
      final double left = center - (tileSize / 2) + xOffset;
      // Нам нужен центр каждого ромба для линии (X и Y от верхнего края)
      return Offset(
        left + (tileSize / 2),
        pathHeight - bottom - (tileSize / 2),
      );
    });

    return Stack(
      children: [
        // 1. СЛОЙ ФОНА (Не скроллится, дает атмосферу)
        _buildChessBackground(context),

        // 2. СЛОЙ СКРОЛЛА (Путь и Линия)
        Positioned.fill(
          child: SingleChildScrollView(
            reverse: true, // Начинаем снизу
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: SizedBox(
                width: containerWidth,
                height: pathHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --- ЛИНИЯ ПУТИ (Рисуется под ромбами) ---
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PathLinePainter(
                          points: linePoints,
                          color: clBrown.withValues(alpha: 0.3),
                        ),
                      ),
                    ),

                    // --- УЗЛЫ (Сами ромбы) ---
                    ...List.generate(_pathElements.length, (index) {
                      final data = _pathElements[index];
                      final double bottom = index * verticalStep;
                      final double xOffset = math.sin(index * 0.8) * amplitude;
                      final double left = center - (tileSize / 2) + xOffset;

                      return Positioned(
                        bottom: bottom,
                        left: left,
                        child: RhombusTile(
                          color: data.color,
                          contentWidget: data.icon != null
                              ? FaIcon(data.icon, color: Colors.white, size: 28)
                              : (data.text != null
                                    ? Text(
                                        data.text!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      )
                                    : null),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Генератор уютного фона с фигурами
  // --- ГЕНЕРАТОР УЮТНОГО ШАХМАТНОГО ФОНА ---
  Widget _buildChessBackground(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // 1. Рисуем сетку на весь экран
          Positioned.fill(child: CustomPaint(painter: ChessGridPainter())),

          // 2. Оставляем твои любимые полупрозрачные фигуры для объема
          Positioned(
            top: -50,
            left: -50,
            child: Opacity(
              opacity: 0.04,
              child: FaIcon(
                FontAwesomeIcons.chessKnight,
                size: 400,
                color: clPrimaryDark,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Opacity(
              opacity: 0.04,
              child: FaIcon(
                FontAwesomeIcons.chessQueen,
                size: 500,
                color: clPrimaryMain,
              ),
            ),
          ),

          // 3. Тонкий градиент сверху и снизу, чтобы сетка не обрывалась резко
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration())),
        ],
      ),
    );
  }
}

// === КЛАСС ДЛЯ ОТРИСОВКИ ЛИНИИ ПУТИ ===
class PathLinePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  PathLinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth =
          20.0 // Толщина линии
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    // Рисуем кривую Безье для плавности между точками
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      // Контрольные точки для легкого изгиба
      final controlPointX = (p1.dx + p2.dx) / 2;
      final controlPointY = (p1.dy + p2.dy) / 2;

      path.quadraticBezierTo(p1.dx, p1.dy, controlPointX, controlPointY);
      path.lineTo(p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Виджет узла (Ромб) с объемными 3D-тенями
class RhombusTile extends StatelessWidget {
  final Color color;
  final Widget? contentWidget;

  const RhombusTile({super.key, required this.color, this.contentWidget});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Уровень выбран!"),
            duration: Duration(milliseconds: 500),
          ),
        );
      },
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
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
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Center(child: contentWidget),
          ),
        ),
      ),
    );
  }
}

// === КЛАСС ДЛЯ ОТРИСОВКИ ШАХМАТНОЙ СЕТКИ НА ФОНЕ ===
class ChessGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Цвета: очень светлый нейтральный и чуть более зеленый "пастельный"
    final paintLight = Paint()..color = const Color.fromARGB(255, 0, 66, 46);
    final paintGreen = Paint()..color = const Color.fromARGB(255, 4, 36, 0);

    const double squareSize = 100.0; // Размер клетки фона

    // Проходимся циклом по всей ширине и высоте экрана
    for (double i = 0; i < size.width; i += squareSize) {
      for (double j = 0; j < size.height; j += squareSize) {
        // Логика шахматного порядка
        final isEven =
            ((i / squareSize).floor() + (j / squareSize).floor()) % 2 == 0;

        canvas.drawRect(
          Rect.fromLTWH(i, j, squareSize, squareSize),
          isEven ? paintLight : paintGreen,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
