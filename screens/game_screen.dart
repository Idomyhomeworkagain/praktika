import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

// Провайдер состояния для выбранного бота (Dart 3 Records для данных)
final botLevels = [
  (name: "Новичок", desc: "Делает случайные ходы"),
  (name: "Любитель", desc: "Знает базовые тактики"),
  (name: "Мастер", desc: "Уничтожит твою самооценку"),
];

class BotIndexNotifier extends Notifier<int> {
  @override
  int build() => 0; // Начальное состояние (индекс 0)

  // Метод для стрелки вправо
  void next(int maxItems) {
    state = (state < maxItems - 1) ? state + 1 : 0;
  }

  // Метод для стрелки влево
  void prev(int maxItems) {
    state = (state > 0) ? state - 1 : maxItems - 1;
  }
}

// Создаем провайдер нового типа
final selectedBotIndexProvider = NotifierProvider<BotIndexNotifier, int>(
  BotIndexNotifier.new,
);

// Теперь это ConsumerWidget
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В реальном проекте контроллер тоже стоит вынести в провайдер,
    // но для пакета chess_board оставим его локальным для простоты инициализации
    final ChessBoardController controller = ChessBoardController();

    // Слушаем изменение индекса бота
    final botIndex = ref.watch(selectedBotIndexProvider);
    final currentBot = botLevels[botIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildGameHeader(context, currentBot),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 600,
                    maxWidth: 600,
                  ),
                  child: ChessBoard(
                    controller: controller,
                    boardColor: BoardColor.green,
                    boardOrientation: PlayerColor.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton("Ход назад", Icons.undo),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionButton("Сдаться", Icons.flag)),
                    const SizedBox(width: 12),
                    _buildActionButton("?", Icons.help_outline, isHelp: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildBotSelector(context, ref, botIndex),
                const SizedBox(height: 24),
                // Заглушка под анализ
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: const Center(child: Text("График оценки позиции")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader(
    BuildContext context,
    ({String desc, String name}) bot,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: clPrimaryMain,
              child: Text("Б", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Бот: ${bot.name}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(bot.desc, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
        Text(
          "00:00",
          style: GoogleFonts.sourceCodePro(
            textStyle: const TextStyle(fontSize: 24, color: clGrayText),
          ),
        ),
      ],
    );
  }

  Widget _buildBotSelector(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  // Вызываем метод prev()
                  onPressed: () => ref
                      .read(selectedBotIndexProvider.notifier)
                      .prev(botLevels.length),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  botLevels[currentIndex].name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  // Вызываем метод next()
                  onPressed: () => ref
                      .read(selectedBotIndexProvider.notifier)
                      .next(botLevels.length),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Здесь будет логика сброса доски и запуска нового бота
              },
              child: const Text("Новая игра"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon, {
    bool isHelp = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isHelp ? Colors.white : clBackground,
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isHelp
          ? Icon(icon, color: clPrimaryMain)
          : Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: clPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
