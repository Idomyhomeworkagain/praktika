// lib/screens/dummy_screens.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme.dart';

// ==========================================
// ЭКРАН ЗАДАЧ (TASKS SCREEN)
// ==========================================
class TasksDummyScreen extends StatelessWidget {
  const TasksDummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Массив заглушек для задач
    final tasks = [
      {"title": "Мат в 1 ход", "icon": FontAwesomeIcons.chessBoard, "progress": 0.8, "count": "40/50"},
      {"title": "Вилка", "icon": FontAwesomeIcons.chessKnight, "progress": 0.5, "count": "25/50"},
      {"title": "Связка", "icon": FontAwesomeIcons.chessBishop, "progress": 0.2, "count": "10/50"},
      {"title": "Открытое нападение", "icon": FontAwesomeIcons.chessRook, "progress": 0.0, "count": "0/50"},
      {"title": "Эндшпиль: Пешки", "icon": FontAwesomeIcons.chessPawn, "progress": 0.1, "count": "5/50"},
      {"title": "Защита Короля", "icon": FontAwesomeIcons.chessKing, "progress": 0.0, "count": "0/50"},
    ];

    return Scaffold(
      backgroundColor: clBackground,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Тренировка тактики", style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32, color: clPrimaryDark)),
            const SizedBox(height: 8),
            Text("Решай задачи, чтобы повысить свой рейтинг", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
            const SizedBox(height: 32),
            
            // Адаптивная сетка для карточек (сама подстраивается под ширину экрана)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350, // Максимальная ширина карточки
                  childAspectRatio: 1.5,   // Пропорции карточки
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(
                    context,
                    title: task["title"] as String,
                    icon: task["icon"],
                    progress: task["progress"] as double,
                    count: task["count"] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, {required String title, required dynamic icon, required double progress, required String count}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20))),
              FaIcon(icon, color: clPrimaryMain, size: 32),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Прогресс", style: Theme.of(context).textTheme.bodySmall),
                  Text(count, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(clPrimaryMain),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ==========================================
// ЭКРАН ПРОФИЛЯ (PROFILE SCREEN)
// ==========================================
class ProfileDummyScreen extends StatelessWidget {
  const ProfileDummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Шапка профиля
            const CircleAvatar(
              radius: 60,
              backgroundColor: clBrown,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text("Михаил Б.", style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32, color: clPrimaryDark)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: clPrimaryMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Эло: 1200 | Любитель", style: TextStyle(color: clPrimaryDark, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            
            const SizedBox(height: 48),

            // Статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatBox(context, "Победы", "45", Colors.green.shade600),
                const SizedBox(width: 24),
                _buildStatBox(context, "Ничьи", "12", Colors.grey.shade600),
                const SizedBox(width: 24),
                _buildStatBox(context, "Поражения", "20", Colors.red.shade600),
              ],
            ),

            const SizedBox(height: 48),

            // Раздел достижений
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Недавние достижения", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.fire, color: Colors.orange, size: 40),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ударный темп", style: Theme.of(context).textTheme.titleLarge),
                      const Text("Вы решали задачи 4 дня подряд!"),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}