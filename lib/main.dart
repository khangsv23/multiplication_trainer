import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MultiplicationApp());
}

class MultiplicationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luyện bảng cửu chương',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  List<int> selectedTables = [];
  String mode = 'practice';

  void startQuiz() {
    if (selectedTables.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizScreen(selectedTables: selectedTables, mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn chế độ")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Chọn các bảng muốn luyện:", style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8,
              children: List.generate(9, (i) {
                int table = i + 1;
                bool selected = selectedTables.contains(table);
                return ChoiceChip(
                  label: Text("Bảng $table"),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (selected)
                        selectedTables.remove(table);
                      else
                        selectedTables.add(table);
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            Text("Chọn chế độ:", style: TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'practice',
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v!),
                ),
                Text("Luyện tập vô hạn"),
                Radio<String>(
                  value: 'test',
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v!),
                ),
                Text("Kiểm tra 10 câu"),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startQuiz,
              child: Text("Bắt đầu"),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<int> selectedTables;
  final String mode;
  QuizScreen({required this.selectedTables, required this.mode});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int num1 = 1;
  int num2 = 1;
  String answer = "";
  int questionCount = 0;
  int correctCount = 0;

  void generateQuestion() {
    final rand = Random();
    num1 = widget.selectedTables[rand.nextInt(widget.selectedTables.length)];
    num2 = rand.nextInt(9) + 1;
    answer = "";
  }

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void submitAnswer() {
    int correctAns = num1 * num2;
    if (answer == correctAns.toString()) {
      correctCount++;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Đúng!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Sai, đáp án là $correctAns")));
    }

    questionCount++;
    if (widget.mode == 'test' && questionCount >= 10) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
              correct: correctCount, total: 10),
        ),
      );
    } else {
      setState(() => generateQuestion());
    }
  }

  void inputDigit(String digit) {
    setState(() {
      answer += digit;
    });
  }

  void backspace() {
    if (answer.isNotEmpty) {
      setState(() {
        answer = answer.substring(0, answer.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trả lời")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$num1 × $num2 = ?", style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            Text(answer, style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: [
                  ...List.generate(9, (i) {
                    String digit = "${i + 1}";
                    return ElevatedButton(
                      onPressed: () => inputDigit(digit),
                      child: Text(digit, style: TextStyle(fontSize: 24)),
                    );
                  }),
                  ElevatedButton(
                    onPressed: backspace,
                    child: Icon(Icons.backspace),
                  ),
                  ElevatedButton(
                    onPressed: () => inputDigit("0"),
                    child: Text("0", style: TextStyle(fontSize: 24)),
                  ),
                  ElevatedButton(
                    onPressed: submitAnswer,
                    child: Text("OK", style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  ResultScreen({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    double percent = (correct / total) * 100;
    return Scaffold(
      appBar: AppBar(title: Text("Kết quả")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Số câu đúng: $correct / $total", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("Tỉ lệ: ${percent.toStringAsFixed(1)}%", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Làm lại"),
            ),
          ],
        ),
      ),
    );
  }
}
