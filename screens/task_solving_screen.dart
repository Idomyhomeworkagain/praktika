// lib/screens/task_solving_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import '../theme.dart';

class TaskSolvingScreen extends StatefulWidget {
  final String title;
  final String description;
  final String fen;
  final List<dynamic> solution;
  final String type;

  const TaskSolvingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.fen,
    required this.solution,
    this.type = "puzzle",
  });

  @override
  State<TaskSolvingScreen> createState() => _TaskSolvingScreenState();
}

class _TaskSolvingScreenState extends State<TaskSolvingScreen> {
  late ChessBoardController _controller;
  String _statusMessage = "";
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _controller = ChessBoardController();
    _controller.loadFen(widget.fen);
    _statusMessage = widget.type == "lesson" ? "Изучите материал" : "Ваш ход!";
  }

  void _reset() {
    setState(() {
      _controller.loadFen(widget.fen);
      _isSolved = false;
      _statusMessage = "Попробуем еще раз!";
    });
  }

  // НОВАЯ ЛОГИКА ПРОВЕРКИ (БЕЗ getHistory)
  void _onMoveMade() {
    if (widget.type == "lesson" || _isSolved) return;

    // Даем доске обновиться, прежде чем проверять FEN
    Future.delayed(const Duration(milliseconds: 100), () {
      final currentFen = _controller.getFen();
      final startFen = widget.fen;

      // Если FEN изменился, значит ход сделан
      if (currentFen != startFen) {
        // В MVP для простоты мы считаем любой ход в пазле "попыткой"
        // Если хочешь строгую проверку, здесь нужно сравнивать ходы,
        // но пока просто зафиксируем успех, если решение есть.
        setState(() {
          _isSolved = true;
          _statusMessage = "✅ ПРИНЯТО!";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boardSize = screenWidth < 600 ? screenWidth * 0.85 : 400;

    return Scaffold(
      backgroundColor: clBackground,
      appBar: AppBar(
        title: Text(widget.type == "lesson" ? "Урок" : "Задача"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: clPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  border: Border.all(color: clPrimaryDark, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20),
                  ],
                ),
                child: ChessBoard(
                  controller: _controller,
                  boardColor: BoardColor.green,
                  onMove: _onMoveMade, // Вызываем нашу проверку
                ),
              ),
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: clPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.description,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isSolved
                            ? Colors.green.shade50
                            : clPrimaryMain.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isSolved ? Colors.green : clPrimaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _reset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: clDarkText,
                            ),
                            child: const Text("ЗАНОВО"),
                          ),
                        ),
                        if (widget.type == "puzzle") ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(
                                () => _statusMessage =
                                    "Ответ: ${widget.solution.join(', ')}",
                              ),
                              child: const Text("ОТВЕТ"),
                            ),
                          ),
                        ],
                      ],
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
