import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PomodoroPage(),
    );
  }
}

enum SessionType { pomodoro, shortBreak, longBreak }

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  static const int _pomodoroMinutes = 25;
  static const int _shortBreakMinutes = 5;
  static const int _longBreakMinutes = 15;

  SessionType _session = SessionType.pomodoro;
  int _remainingSeconds = _pomodoroMinutes * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPressed = false;

  int _minutesForSession(SessionType session) {
    switch (session) {
      case SessionType.pomodoro:
        return _pomodoroMinutes;
      case SessionType.shortBreak:
        return _shortBreakMinutes;
      case SessionType.longBreak:
        return _longBreakMinutes;
    }
  }

  void _selectSession(SessionType session) {
    _timer?.cancel();
    setState(() {
      _session = session;
      _isRunning = false;
      _remainingSeconds = _minutesForSession(session) * 60;
    });
  }

  void _startPause() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
  }

  String get _timeText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- Tab pilihan sesi ----
                  Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTab('Pomodoro', SessionType.pomodoro),
                    _buildTab('Short Break', SessionType.shortBreak),
                    _buildTab('Long Break', SessionType.longBreak),
                  ],
                ),
                const SizedBox(height: 32),

                // ---- Angka timer ----
                Text(
                  _timeText,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                ),
                const SizedBox(height: 32),

                // ---- Tombol Start/Pause ----
                GestureDetector(
                  onTap: _startPause,
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 0),
                      ],
                    ),
                    child: Text(
                      _isRunning ? 'PAUSE' : 'START',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, SessionType session) {
    final isActive = _session == session;
    return GestureDetector(
      onTap: () => _selectSession(session),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}