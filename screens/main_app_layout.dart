import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Для лого LEAD
import '../theme.dart';

class MainAppLayout extends StatelessWidget {
  final Widget child; // Контент, который подставляет роутер

  const MainAppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Очень светлый фон самого окна
      body: Center(
        child: Container(
          // Фиксированная ширина контейнера для веба, как на макетах (UI/UX)
          constraints: const BoxConstraints(maxWidth: 1200, minWidth: 600),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Кастомный Навигационный Бар (как на скрине)
              _buildTopNavBar(context),

              // Основной контент (меняется)
              Expanded(child: child), // Сюда рендерятся экраны
            ],
          ),
        ),
      ),
    );
  }

  // Верстка Навигационного Бара (как на скрине)
  Widget _buildTopNavBar(BuildContext context) {
    // Получаем текущий URL-путь
    final location = GoRouterState.of(context).uri.path;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Лого (С использованием Dela Gothic)
          Text(
            "CHESSLEAD",
            style: GoogleFonts.delaGothicOne(
              textStyle: const TextStyle(
                fontSize: 24,
                color: clPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Меню навигации (с иконками и русским текстом)
          Row(
            children: [
              _buildNavButton(
                context,
                "игра с ботом",
                Icons.smart_toy_outlined,
                '/game',
                location == '/game',
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                context,
                "уроки",
                Icons.menu_book_outlined,
                '/lessons',
                location == '/lessons',
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                context,
                "задачи",
                Icons.lightbulb_outline,
                '/tasks',
                location == '/tasks',
              ),
            ],
          ),

          // Профиль (справа: огонь, 4, аватар)
          Row(
            children: [
              _buildProfileItem(
                context,
                Icons.local_fire_department_outlined,
                "4",
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Кнопки навигации с иконками и русским текстом
  Widget _buildNavButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    bool isActive,
  ) {
    return InkWell(
      onTap: () => context.go(route), // Современная веб-навигация
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: isActive ? clPrimaryMain : clGrayText, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isActive ? clPrimaryMain : clGrayText,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Элементы профиля (например, огонь и цифра)
  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
