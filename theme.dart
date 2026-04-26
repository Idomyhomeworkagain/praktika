// lib/theme.dart
import 'package:flutter/material.dart';

// Цвета Тимлида: Стиль "Уютная классика"
const Color clPrimaryMain = Color(0xFF6A8E53); // Благородный шахматный зеленый
const Color clPrimaryDark = Color(0xFF425E30); // Глубокий темный зеленый для акцентов
const Color clBrown = Color(0xFF9E6B41);       // Теплое, полированное дерево
const Color clBackground = Color(0xFFF1EDE4);  // Кремовый, "бумажный" фон (не режет глаза)
const Color clDarkText = Color(0xFF2C2C2C);    // Мягкий черный для текста
const Color clGrayText = Color(0xFF808080);

final ThemeData chessLeadTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: clBackground,

  fontFamily: 'Roboto',

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: clPrimaryMain,
      foregroundColor: const Color.fromARGB(255, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4, // Добавили чуть больше тени кнопкам
    ),
  ),

  textTheme: const TextTheme(
    displayMedium: TextStyle(color: clDarkText, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: clDarkText, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(color: clDarkText),
    bodySmall: TextStyle(color: clGrayText),
  ),
);
