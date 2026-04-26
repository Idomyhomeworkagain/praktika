import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/api_provider.dart';

final botLevels = [
  (name: "Новичок", desc: "Делает случайные ходы"),
  (name: "Любитель", desc: "Знает базовые тактики"),
  (name: "Мастер", desc: "Уничтожит твою самооценку"),
];

class BotIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void next(int maxItems) {
    state = (state < maxItems - 1) ? state + 1 : 0;
  }

  void prev(int maxItems) {
    state = (state > 0) ? state - 1 : maxItems - 1;
  }
}

final selectedBotIndexProvider = NotifierProvider<BotIndexNotifier, int>(
  BotIndexNotifier.new,
);

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final ChessBoardController _controller = ChessBoardController();
  bool _isBotThinking = false;

  Future<void> _onMoveMade() async {
    final fen = _controller.getFen();
    final isBlackTurn = fen.split(' ')[1] == 'b';

    if (isBlackTurn && !_isBotThinking) {
      setState(() {
        _isBotThinking = true;
      }); // Включаем загрузку

      try {
        final botLevel = ref.read(selectedBotIndexProvider);
        // Делаем запрос к серверу
        final response = await ref.read(apiProvider).getBotMove(fen, botLevel);

        if (response.containsKey('best_move')) {
          final moveStr = response['best_move'].toString();
          Future.delayed(const Duration(milliseconds: 300), () {
            _controller.makeMove(
              from: moveStr.substring(0, 2),
              to: moveStr.substring(2, 4),
            );
          });
        }
      } catch (e) {
        print("Ошибка связи: $e");
      } finally {
        // ВАЖНО: Выключаем загрузку в любом случае (даже при ошибке)
        if (mounted) {
          setState(() {
            _isBotThinking = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ФИКС: Объявляем screenWidth здесь
    double screenWidth = MediaQuery.of(context).size.width;
    // ФИКС: Уменьшаем размер доски (400px или 90% экрана)
    double boardSize = screenWidth < 600 ? screenWidth * 0.9 : 400;

    return Scaffold(
      backgroundColor: clBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 40,
            runSpacing: 20,
            children: [
              Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: clPrimaryDark, width: 4),
                ),
                child: Stack(
                  children: [
                    ChessBoard(controller: _controller, onMove: _onMoveMade),
                    if (_isBotThinking)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Text(
                      "ИГРА С БОТОМ",
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    // ... (тут кнопки переключения бота как были)
                    ElevatedButton(
                      onPressed: () => _controller.resetBoard(),
                      child: const Text("НОВАЯ ИГРА"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
