import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartStudentDashboardApp());
}

// ══════════════════════════════════════════
// COLORS
// ══════════════════════════════════════════
class AppColors {
  static const Color accentBlue   = Color(0xFF0071E3);
  static const Color accentGreen  = Color(0xFF34C759);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed    = Color(0xFFFF3B30);
  static const Color accentPurple = Color(0xFFAF52DE);

  // Light
  static Color surfaceLight     = Colors.white.withValues(alpha: 0.45);
  static Color surfaceHoverLight= Colors.white.withValues(alpha: 0.65);
  static Color borderLight      = Colors.white.withValues(alpha: 0.65);
  static Color inputBgLight     = Colors.white.withValues(alpha: 0.35);
  static Color textPrimLight    = const Color(0xFF1D1D1F);
  static Color textSecLight     = const Color(0xFF424245);
  static Color textTertLight    = const Color(0xFF6E6E73);

  // Dark
  static Color surfaceDark      = const Color(0xFF1C1C26).withValues(alpha: 0.48);
  static Color surfaceHoverDark = const Color(0xFF2D2D3C).withValues(alpha: 0.62);
  static Color borderDark       = Colors.white.withValues(alpha: 0.18);
  static Color inputBgDark      = Colors.white.withValues(alpha: 0.08);
  static Color textPrimDark     = const Color(0xFFF5F5F7);
  static Color textSecDark      = const Color(0xFFA1A1A6);
  static Color textTertDark     = const Color(0xFF6E6E73);
}

// ══════════════════════════════════════════
// TASK MODEL
// ══════════════════════════════════════════
class Task {
  String title;
  String subject;
  DateTime deadline;
  bool completed;

  Task({required this.title, required this.subject, required this.deadline, this.completed = false});

  Map<String, dynamic> toJson() => {
    'title': title, 'subject': subject,
    'deadline': deadline.toIso8601String(), 'completed': completed,
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    title: j['title'], subject: j['subject'],
    deadline: DateTime.parse(j['deadline']), completed: j['completed'] ?? false,
  );
}

// ══════════════════════════════════════════
// ROOT APP
// ══════════════════════════════════════════
class SmartStudentDashboardApp extends StatefulWidget {
  const SmartStudentDashboardApp({super.key});
  @override
  State<SmartStudentDashboardApp> createState() => _AppState();
}

class _AppState extends State<SmartStudentDashboardApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Student Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, fontFamily: 'Inter', useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: 'Inter', useMaterial3: true),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardScreen(isDark: _isDark, onToggle: () => setState(() => _isDark = !_isDark)),
    );
  }
}

// ══════════════════════════════════════════
// LIQUID CARD
// ══════════════════════════════════════════
class LiquidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool isDark;

  const LiquidCard({super.key, required this.child, required this.isDark,
    this.padding = const EdgeInsets.all(28)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: isDark
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 60, offset: const Offset(0,24))]
          : [BoxShadow(color: const Color(0xFF1F2687).withValues(alpha: 0.12), blurRadius: 50, offset: const Offset(0,20))],
      ),
      child: child,
    );
  }
}

// ══════════════════════════════════════════
// LIQUID PRIMARY BUTTON
// ══════════════════════════════════════════
class LiquidBtnPrimary extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets padding;

  const LiquidBtnPrimary({super.key, required this.child, required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 13)});

  @override
  State<LiquidBtnPrimary> createState() => _LiquidBtnPrimaryState();
}

class _LiquidBtnPrimaryState extends State<LiquidBtnPrimary>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.91).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.38), blurRadius: 20, offset: const Offset(0,6)),
              BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(0,1)),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// LIQUID SECONDARY BUTTON
// ══════════════════════════════════════════
class LiquidBtnSecondary extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isDark;

  const LiquidBtnSecondary({super.key, required this.child, required this.onTap, required this.isDark});

  @override
  State<LiquidBtnSecondary> createState() => _LiquidBtnSecondaryState();
}

class _LiquidBtnSecondaryState extends State<LiquidBtnSecondary>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: widget.isDark ? AppColors.borderDark : AppColors.borderLight),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 0, offset: const Offset(0,1))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// LIQUID ICON BUTTON (round)
// ══════════════════════════════════════════
class LiquidIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const LiquidIconBtn({super.key, required this.icon, required this.onTap, required this.isDark});

  @override
  State<LiquidIconBtn> createState() => _LiquidIconBtnState();
}

class _LiquidIconBtnState extends State<LiquidIconBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _rot;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _rot   = Tween(begin: 0.0, end: -0.26).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(angle: _rot.value, child: child),
        ),
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
            shape: BoxShape.circle,
            border: Border.all(color: widget.isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Icon(widget.icon, size: 18,
            color: widget.isDark ? AppColors.textPrimDark : AppColors.textPrimLight),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// TIMER RING PAINTER
// ══════════════════════════════════════════
class RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color bgColor;

  RingPainter({required this.progress, required this.ringColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 12;
    const sw = 10.0;

    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi, false,
      Paint()..color = bgColor..style = PaintingStyle.stroke..strokeWidth = sw);

    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * progress, false,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
  }

  @override
  bool shouldRepaint(RingPainter o) => o.progress != progress || o.ringColor != ringColor;
}

// ══════════════════════════════════════════
// GLASS INPUT
// ══════════════════════════════════════════
class GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;

  const GlassInput({super.key, required this.controller, required this.hint, required this.isDark});

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg     = widget.isDark ? AppColors.inputBgDark : AppColors.inputBgLight;
    final tp     = widget.isDark ? AppColors.textPrimDark : AppColors.textPrimLight;
    final ts     = widget.isDark ? AppColors.textSecDark : AppColors.textSecLight;

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _focused ? AppColors.accentBlue : border, width: _focused ? 1.5 : 1),
          boxShadow: _focused
            ? [BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.25), blurRadius: 0, spreadRadius: 3)]
            : [],
        ),
        child: TextField(
          controller: widget.controller,
          style: TextStyle(fontSize: 14, color: tp),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: 14, color: ts),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// GLASS DROPDOWN
// ══════════════════════════════════════════
class GlassDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;
  final String hint;

  const GlassDropdown({super.key, required this.value, required this.items,
    required this.onChanged, required this.isDark, required this.hint});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bg     = isDark ? AppColors.inputBgDark : AppColors.inputBgLight;
    final tp     = isDark ? AppColors.textPrimDark : AppColors.textPrimLight;
    final ts     = isDark ? AppColors.textSecDark  : AppColors.textSecLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 14, color: ts)),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1C1C26) : Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: ts, size: 20),
          items: items.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s, style: TextStyle(fontSize: 14, color: tp)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// CONFETTI
// ══════════════════════════════════════════
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});
  @override
  State<ConfettiOverlay> createState() => _ConfettiState();
}

class _ConfettiState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
    _particles = List.generate(45, (_) => _Particle(
      x: _rng.nextDouble(),
      color: [AppColors.accentBlue, AppColors.accentGreen, AppColors.accentOrange,
              AppColors.accentPurple, AppColors.accentRed][_rng.nextInt(5)],
      speed: 0.3 + _rng.nextDouble() * 0.7,
      spread: (_rng.nextDouble() - 0.5) * 0.5,
      size: 5 + _rng.nextDouble() * 8,
      rot: _rng.nextDouble() * pi * 2,
    ));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => CustomPaint(
      painter: _ConfettiPainter(_particles, _ctrl.value),
      size: Size.infinite,
    ),
  );
}

class _Particle {
  final double x, speed, spread, size, rot;
  final Color color;
  _Particle({required this.x, required this.color, required this.speed,
    required this.spread, required this.size, required this.rot});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> p;
  final double t;
  _ConfettiPainter(this.p, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in p) {
      final progress = (t * particle.speed).clamp(0.0, 1.0);
      final x = (particle.x + particle.spread * progress) * size.width;
      final y = (0.65 + progress * 0.6) * size.height;
      final alpha = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = particle.color.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rot + progress * pi * 4);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.5), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => o.t != t;
}

// ══════════════════════════════════════════
// DASHBOARD SCREEN
// ══════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const DashboardScreen({super.key, required this.isDark, required this.onToggle});

  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> with TickerProviderStateMixin {
  // ── User
  String _name = 'Student';

  // ── Clock
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // ── Timer
  static const _durations = {'focus': 25 * 60, 'shortBreak': 5 * 60, 'longBreak': 15 * 60};
  static const _modeColors = {
    'focus': AppColors.accentBlue,
    'shortBreak': AppColors.accentGreen,
    'longBreak': AppColors.accentPurple,
  };
  String _mode = 'focus';
  int _timeLeft = 25 * 60;
  bool _running = false;
  Timer? _tick;
  String _stateLabel = 'Ready';
  int _modeIdx = 0;

  // Pill
  late AnimationController _pillCtrl;
  late Animation<double> _pillAnim;

  // ── Tasks
  List<Task> _tasks = [];
  final _titleCtrl = TextEditingController();
  String _subject = '';
  DateTime? _deadline;

  // ── Confetti
  bool _confetti = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();

    _pillCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _pillAnim = Tween(begin: 0.0, end: 0.0)
        .animate(CurvedAnimation(parent: _pillCtrl, curve: const Cubic(0.34, 1.56, 0.64, 1)));

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _tick?.cancel();
    _pillCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── PREFS
  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = p.getString('app_user_name') ?? 'Student';
      final raw = p.getString('app_tasks');
      if (raw != null) {
        _tasks = (jsonDecode(raw) as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
  }

  Future<void> _saveTasks() async {
    final p = await SharedPreferences.getInstance();
    p.setString('app_tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> _saveName(String n) async {
    final p = await SharedPreferences.getInstance();
    p.setString('app_user_name', n);
  }

  // ── GREETING
  String get _greeting {
    final h = _now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _dateStr {
    const wd = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${wd[_now.weekday - 1]}, ${mo[_now.month - 1]} ${_now.day}, ${_now.year}';
  }

  String get _clockStr {
    final h = _now.hour.toString().padLeft(2,'0');
    final m = _now.minute.toString().padLeft(2,'0');
    final s = _now.second.toString().padLeft(2,'0');
    return '$h:$m:$s';
  }

  // ── TIMER
  void _switchMode(String mode, int idx) {
    if (idx == _modeIdx) return;
    final prev = _pillAnim.value;
    _modeIdx = idx;
    _pillAnim = Tween(begin: prev, end: idx.toDouble())
        .animate(CurvedAnimation(parent: _pillCtrl, curve: const Cubic(0.34, 1.56, 0.64, 1)));
    _pillCtrl.forward(from: 0);
    _tick?.cancel();
    setState(() {
      _mode = mode;
      _running = false;
      _timeLeft = _durations[mode]!;
      _stateLabel = 'Ready';
    });
  }

  void _toggleTimer() {
    if (_running) {
      _tick?.cancel();
      setState(() { _running = false; _stateLabel = 'Paused'; });
    } else {
      setState(() {
        _running = true;
        _stateLabel = _mode == 'focus' ? 'Focusing' : 'Break Time';
      });
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          _tick?.cancel();
          setState(() { _running = false; _stateLabel = 'Done!'; });
          _fireConfetti();
          _resetTimer();
          _showDoneDialog();
        }
      });
    }
  }

  void _resetTimer() {
    _tick?.cancel();
    setState(() { _running = false; _timeLeft = _durations[_mode]!; _stateLabel = 'Ready'; });
  }

  String get _timerDisplay {
    final m = (_timeLeft ~/ 60).toString().padLeft(2,'0');
    final s = (_timeLeft % 60).toString().padLeft(2,'0');
    return '$m:$s';
  }

  double get _progress => _timeLeft / _durations[_mode]!;

  void _showDoneDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1C1C26) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Session Complete! 🎉',
          style: TextStyle(fontWeight: FontWeight.w700,
            color: widget.isDark ? AppColors.textPrimDark : AppColors.textPrimLight)),
        content: Text('Great work! Time for a break.',
          style: TextStyle(color: widget.isDark ? AppColors.textSecDark : AppColors.textSecLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── CONFETTI
  void _fireConfetti() {
    setState(() => _confetti = true);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _confetti = false);
    });
  }

  // ── TASKS
  void _addTask() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _subject.isEmpty || _deadline == null) return;
    setState(() {
      _tasks.add(Task(title: title, subject: _subject, deadline: _deadline!));
      _titleCtrl.clear();
      _subject = '';
      _deadline = null;
    });
    _saveTasks();
  }

  void _toggleTask(int i) {
    setState(() => _tasks[i].completed = !_tasks[i].completed);
    if (_tasks[i].completed) _fireConfetti();
    _saveTasks();
  }

  void _deleteTask(int i) {
    setState(() => _tasks.removeAt(i));
    _saveTasks();
  }

  String _fmtDeadline(DateTime d) {
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '${mo[d.month-1]} ${d.day}, $h:${d.minute.toString().padLeft(2,'0')} $ampm';
  }

  Widget _badge(DateTime deadline) {
    final diff = deadline.difference(DateTime.now()).inHours;
    Color bg, fg, bd;
    IconData icon;
    String label;

    if (diff < 0) {
      bg = AppColors.accentRed.withValues(alpha: 0.15); fg = AppColors.accentRed;
      bd = AppColors.accentRed.withValues(alpha: 0.3); icon = Icons.warning_amber_rounded; label = 'Overdue';
    } else if (diff <= 24) {
      bg = AppColors.accentRed.withValues(alpha: 0.15); fg = AppColors.accentRed;
      bd = AppColors.accentRed.withValues(alpha: 0.3); icon = Icons.access_time_rounded; label = 'Due < 24h';
    } else if (diff <= 72) {
      bg = AppColors.accentOrange.withValues(alpha: 0.15); fg = AppColors.accentOrange;
      bd = AppColors.accentOrange.withValues(alpha: 0.3); icon = Icons.access_time_rounded; label = 'Due < 3 Days';
    } else {
      bg = AppColors.accentGreen.withValues(alpha: 0.15); fg = AppColors.accentGreen;
      bd = AppColors.accentGreen.withValues(alpha: 0.3); icon = Icons.calendar_today_rounded; label = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), border: Border.all(color: bd)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: fg),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _editName() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1C1C26) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Your Name', style: TextStyle(fontWeight: FontWeight.w700,
          color: widget.isDark ? AppColors.textPrimDark : AppColors.textPrimLight)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: TextStyle(color: widget.isDark ? AppColors.textPrimDark : AppColors.textPrimLight),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: widget.isDark ? AppColors.textSecDark : AppColors.textSecLight),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.accentBlue))),
          TextButton(
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isNotEmpty) { setState(() => _name = n); _saveName(n); }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    final tp  = d ? AppColors.textPrimDark  : AppColors.textPrimLight;
    final ts  = d ? AppColors.textSecDark   : AppColors.textSecLight;
    final ttr = d ? AppColors.textTertDark  : AppColors.textTertLight;
    final ibg = d ? AppColors.inputBgDark   : AppColors.inputBgLight;
    final bdr = d ? AppColors.borderDark    : AppColors.borderLight;

    final bgGrad = d
      ? const RadialGradient(center: Alignment(0.6,-0.6), radius: 1.2,
          colors: [Color(0xFF2E0854), Color(0xFF0F172A), Color(0xFF05050A)])
      : const RadialGradient(center: Alignment(-0.7,-0.7), radius: 1.4,
          colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC), Color(0xFFE0F2FE)]);

    return Scaffold(
      body: Stack(
        children: [
          // BG
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            decoration: BoxDecoration(gradient: bgGrad),
          ),

          // CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(d, tp, ts, ibg, bdr),
                  const SizedBox(height: 20),
                  _buildBody(d, tp, ts, ttr, ibg, bdr),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Smart Student Focus & Study Dashboard • Apple Liquid Glass Standards',
                      style: TextStyle(fontSize: 12, color: ts),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // CONFETTI
          if (_confetti) const IgnorePointer(child: ConfettiOverlay()),
        ],
      ),
    );
  }

  // ── HEADER
  Widget _buildHeader(bool d, Color tp, Color ts, Color ibg, Color bdr) {
    return LiquidCard(
      isDark: d,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('$_greeting, ',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                        letterSpacing: -0.5, color: tp)),
                    GestureDetector(
                      onTap: _editName,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: const Border(bottom: BorderSide(color: AppColors.accentBlue, width: 2)),
                        ),
                        child: Text(_name,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                            letterSpacing: -0.5, color: tp)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_dateStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ts)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Clock badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: ibg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bdr),
            ),
            child: Text(_clockStr,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                fontFamily: 'monospace', letterSpacing: 1.2, color: tp)),
          ),
          const SizedBox(width: 12),
          LiquidIconBtn(
            icon: d ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            onTap: widget.onToggle,
            isDark: d,
          ),
        ],
      ),
    );
  }

  // ── BODY (responsive)
  Widget _buildBody(bool d, Color tp, Color ts, Color ttr, Color ibg, Color bdr) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if (constraints.maxWidth > 860) {
          // Wide: side by side
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: constraints.maxWidth * 0.40,
                child: _buildTimerCard(d, tp, ts, ibg, bdr)),
              const SizedBox(width: 20),
              Expanded(child: _buildTaskCard(d, tp, ts, ttr, ibg, bdr)),
            ],
          );
        } else {
          // Narrow: stacked
          return Column(children: [
            _buildTimerCard(d, tp, ts, ibg, bdr),
            const SizedBox(height: 20),
            _buildTaskCard(d, tp, ts, ttr, ibg, bdr),
          ]);
        }
      },
    );
  }

  // ── TIMER CARD
  Widget _buildTimerCard(bool d, Color tp, Color ts, Color ibg, Color bdr) {
    final modeLabels = ['Focus', 'Short Break', 'Long Break'];
    final modeKeys   = ['focus', 'shortBreak', 'longBreak'];
    final ringColor  = _modeColors[_mode]!;

    return LiquidCard(
      isDark: d,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section title
          Row(children: [
            const Icon(Icons.timer_outlined, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: 10),
            Text('Focus Timer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: tp)),
          ]),
          const SizedBox(height: 24),

          // Pill switcher
          AnimatedBuilder(
            animation: _pillAnim,
            builder: (_, __) => LayoutBuilder(
              builder: (_, c) {
                final segW = c.maxWidth / 3;
                return Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: ibg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: bdr),
                  ),
                  child: Stack(
                    children: [
                      // Sliding pill
                      Positioned(
                        left: _pillAnim.value * segW + 4,
                        top: 4, bottom: 4,
                        width: segW - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: d ? AppColors.surfaceHoverDark : AppColors.surfaceHoverLight,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: bdr),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12),
                            ],
                          ),
                        ),
                      ),
                      // Buttons row
                      Row(
                        children: List.generate(3, (i) => Expanded(
                          child: GestureDetector(
                            onTap: () => _switchMode(modeKeys[i], i),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Text(modeLabels[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: i == _modeIdx ? tp : ts,
                                )),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Ring
          SizedBox(
            width: 220, height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: RingPainter(progress: _progress, ringColor: ringColor, bgColor: bdr),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_timerDisplay,
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700,
                        letterSpacing: -1.5, color: tp,
                        fontFeatures: const [FontFeature.tabularFigures()])),
                    const SizedBox(height: 4),
                    Text(_stateLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: ts, letterSpacing: 1.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidBtnPrimary(
                onTap: _toggleTimer,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(_running ? 'Pause' : 'Start',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ]),
              ),
              const SizedBox(width: 12),
              LiquidBtnSecondary(
                isDark: d,
                onTap: _resetTimer,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restart_alt_rounded, size: 18, color: tp),
                  const SizedBox(width: 6),
                  Text('Reset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tp)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TASK CARD
  Widget _buildTaskCard(bool d, Color tp, Color ts, Color ttr, Color ibg, Color bdr) {
    return LiquidCard(
      isDark: d,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section title
          Row(children: [
            const Icon(Icons.checklist_rounded, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: 10),
            Text('Assignments & Tasks',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: tp)),
          ]),
          const SizedBox(height: 22),

          // Form — use Column not Wrap to avoid unbounded width issues
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: title + subject
              Row(children: [
                Expanded(flex: 3, child: GlassInput(controller: _titleCtrl,
                  hint: 'Assignment title...', isDark: d)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: SizedBox(
                  height: 48,
                  child: GlassDropdown(
                    value: _subject.isEmpty ? null : _subject,
                    hint: 'Subject',
                    items: const ['Math','Programming','English','Science','General'],
                    isDark: d,
                    onChanged: (v) => setState(() => _subject = v ?? ''),
                  ),
                )),
              ]),
              const SizedBox(height: 10),
              // Row 2: deadline + add btn
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDeadline,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: ibg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: bdr),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _deadline == null ? 'Pick deadline...' : _fmtDeadline(_deadline!),
                        style: TextStyle(fontSize: 14,
                          color: _deadline == null ? ts : tp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                LiquidBtnPrimary(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  onTap: _addTask,
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 18),

          // Task list
          if (_tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(children: [
                Icon(Icons.calendar_today_outlined, size: 26, color: ttr),
                const SizedBox(height: 10),
                Text('No assignments queued up. All caught up!',
                  style: TextStyle(fontSize: 14, color: ts), textAlign: TextAlign.center),
              ]),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TaskRow(
                task: _tasks[i],
                isDark: d,
                tp: tp, ts: ts, ttr: ttr, ibg: ibg, bdr: bdr,
                badge: _badge(_tasks[i].deadline),
                deadlineStr: _fmtDeadline(_tasks[i].deadline),
                onToggle: () => _toggleTask(i),
                onDelete: () => _deleteTask(i),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// TASK ROW
// ══════════════════════════════════════════
class _TaskRow extends StatefulWidget {
  final Task task;
  final bool isDark;
  final Color tp, ts, ttr, ibg, bdr;
  final Widget badge;
  final String deadlineStr;
  final VoidCallback onToggle, onDelete;

  const _TaskRow({
    required this.task, required this.isDark,
    required this.tp, required this.ts, required this.ttr,
    required this.ibg, required this.bdr,
    required this.badge, required this.deadlineStr,
    required this.onToggle, required this.onDelete,
  });

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> with SingleTickerProviderStateMixin {
  late AnimationController _hCtrl;
  late Animation<double> _hAnim;
  bool _delHover = false;

  @override
  void initState() {
    super.initState();
    _hCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _hAnim = Tween(begin: 0.0, end: -2.0)
        .animate(CurvedAnimation(parent: _hCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _hCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hCtrl.forward(),
      onExit: (_) => _hCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _hAnim.value),
          child: child,
        ),
        child: AnimatedOpacity(
          opacity: widget.task.completed ? 0.62 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: widget.ibg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.bdr),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.35), blurRadius: 0, offset: const Offset(0,1))],
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: const Cubic(0.34, 1.8, 0.64, 1),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.task.completed ? AppColors.accentGreen : widget.ibg,
                      border: Border.all(
                        color: widget.task.completed ? AppColors.accentGreen : widget.ts,
                        width: 2,
                      ),
                      boxShadow: widget.task.completed
                        ? [BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.4), blurRadius: 8)]
                        : [],
                    ),
                    child: widget.task.completed
                      ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                      : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.task.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: widget.tp,
                          decoration: widget.task.completed ? TextDecoration.lineThrough : null,
                          decorationColor: widget.ttr,
                        )),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
                          ),
                          child: Text(widget.task.subject,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppColors.accentBlue)),
                        ),
                        const SizedBox(width: 8),
                        Flexible(child: Text(widget.deadlineStr,
                          style: TextStyle(fontSize: 11, color: widget.ts),
                          overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Badge
                widget.badge,
                const SizedBox(width: 8),

                // Delete
                MouseRegion(
                  onEnter: (_) => setState(() => _delHover = true),
                  onExit: (_) => setState(() => _delHover = false),
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: _delHover ? AppColors.accentRed.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline_rounded, size: 17,
                        color: _delHover ? AppColors.accentRed : widget.ttr),
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
}
