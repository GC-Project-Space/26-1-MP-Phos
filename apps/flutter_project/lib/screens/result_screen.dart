import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Result', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Rendered Photo Strip', style: TextStyle(color: Colors.white))),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // 모든 스택을 지우고 첫 화면(Home)으로 복귀
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Save Device'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9D72FF), foregroundColor: Colors.white),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context), // 이전 화면(프레임 선택)으로 복귀
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}