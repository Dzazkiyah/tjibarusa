// lib/screens/kuis_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'checkin_screen.dart';

// ════════════════════════════════════════════════════════════════════════════════
// STORAGE
// ════════════════════════════════════════════════════════════════════════════════
class KuisStorage {
  static int lastScore   = 0;
  static int totalPlayed = 0;

  static final Map<int, int> bestScorePerLevel = {0: 0, 1: 0, 2: 0};
  static final Map<int, bool> levelCompleted   = {0: false, 1: false, 2: false};

  static void saveResult(int levelIndex, int score, int total) {
    lastScore   += score;
    totalPlayed += 1;
    if (score > (bestScorePerLevel[levelIndex] ?? 0)) {
      bestScorePerLevel[levelIndex] = score;
    }
    if (score == total) {
      levelCompleted[levelIndex] = true;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// LEVEL CONFIG
// ════════════════════════════════════════════════════════════════════════════════
class KuisLevel {
  final int index;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<KuisQuestion> questions;
  final int unlockRequirement;

  const KuisLevel({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.questions,
    required this.unlockRequirement,
  });

  bool get isUnlocked {
    if (index == 0) return true;
    final prevBest = KuisStorage.bestScorePerLevel[index - 1] ?? 0;
    final prevTotal = _levelData[index - 1].questions.length;
    return prevBest >= (prevTotal * 0.6).ceil();
  }

  int get bestScore => KuisStorage.bestScorePerLevel[index] ?? 0;
  bool get isCompleted => KuisStorage.levelCompleted[index] ?? false;
}

// ─── Data soal per level (5 soal per level, total 15 soal) ─────────────────────
final _levelData = [
  KuisLevel(
    index: 0,
    title: 'Pemula',
    subtitle: 'Kenalan dulu sama Cibarusah',
    emoji: '🌱',
    color: const Color(0xFF4CAF50),
    unlockRequirement: 0,
    questions: DummyData.kuis.take(5).toList(),  // 5 soal pertama
  ),
  KuisLevel(
    index: 1,
    title: 'Penjelajah',
    subtitle: 'Gali lebih dalam sejarahnya',
    emoji: '🗺️',
    color: const Color(0xFF2196F3),
    unlockRequirement: 2,
    questions: DummyData.kuis.skip(5).take(5).toList(),  // 5 soal berikutnya
  ),
  KuisLevel(
    index: 2,
    title: 'Penjaga Sejarah',
    subtitle: 'Buktikan kamu ahlinya!',
    emoji: '🏛️',
    color: AppColors.gold,
    unlockRequirement: 2,
    questions: DummyData.kuis.skip(10).take(5).toList(),  // 5 soal terakhir
  ),
];

// ════════════════════════════════════════════════════════════════════════════════
// KUIS SCREEN — entry point (Level Select)
// ════════════════════════════════════════════════════════════════════════════════
class KuisScreen extends StatefulWidget {
  const KuisScreen({super.key});

  @override
  State<KuisScreen> createState() => _KuisScreenState();
}

class _KuisScreenState extends State<KuisScreen> {
  void _startLevel(KuisLevel level) {
    if (!level.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selesaikan level "${_levelData[level.index - 1].title}" dulu ya!',
          ),
          backgroundColor: AppColors.navyMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _KuisPlayScreen(level: level),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        foregroundColor: AppColors.white,
        title: Text('Kuis Pengetahuan',
            style: AppText.heading(18, color: AppColors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 20 : 40,
          vertical: 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navyDeep, AppColors.navyMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      Text('Uji Pengetahuanmu!',
                          style: AppText.display(22, color: AppColors.white)),
                      const SizedBox(height: 6),
                      Text(
                        'Selesaikan semua level dan jadi Penjaga Sejarah Cibarusah',
                        style: AppText.body(13,
                            color: AppColors.white.withOpacity(0.72)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatChip(
                            icon: Icons.quiz_rounded,
                            label: '${KuisStorage.totalPlayed}x dimainkan',
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.star_rounded,
                            label: '${KuisStorage.lastScore} total skor',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                Text('Pilih Level', style: AppText.heading(18)),
                const SizedBox(height: 14),

                ..._levelData.map((level) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LevelCard(
                        level: level,
                        onTap: () => _startLevel(level),
                      ),
                    )),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.navyDeep.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.gold, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kamu perlu menjawab minimal 60% benar untuk membuka level berikutnya.',
                          style: AppText.body(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const CheckInScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
              break;
          }
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final KuisLevel level;
  final VoidCallback onTap;
  const _LevelCard({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unlocked = level.isUnlocked;
    final best = level.bestScore;
    final total = level.questions.length;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.white : AppColors.grey100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: level.isCompleted
                ? level.color.withOpacity(0.5)
                : AppColors.grey300.withOpacity(0.5),
            width: level.isCompleted ? 2 : 1,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: AppColors.navyDeep.withOpacity(0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: unlocked
                    ? level.color.withOpacity(0.12)
                    : AppColors.grey300.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  unlocked ? level.emoji : '🔒',
                  style: TextStyle(
                      fontSize: 26,
                      color: unlocked ? null : Colors.black26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(level.title,
                        style: AppText.heading(15,
                            color: unlocked
                                ? AppColors.navyDeep
                                : AppColors.grey500)),
                    const SizedBox(width: 8),
                    if (level.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: level.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('✓ Lulus',
                            style: AppText.label(10, color: level.color)),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  Text(level.subtitle,
                      style: AppText.body(12,
                          color: unlocked
                              ? AppColors.grey500
                              : AppColors.grey300)),
                  const SizedBox(height: 8),
                  if (unlocked) ...[
                    Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: total > 0 ? best / total : 0,
                            backgroundColor: AppColors.grey100,
                            color: level.color,
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$best/$total',
                          style: AppText.label(11, color: AppColors.grey500)),
                    ]),
                  ] else ...[
                    Text(
                      'Selesaikan level sebelumnya dulu',
                      style: AppText.body(11, color: AppColors.grey300),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              unlocked
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.lock_outline_rounded,
              size: 16,
              color: unlocked ? AppColors.navyMid : AppColors.grey300,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppColors.gold, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: AppText.label(11, color: AppColors.white)),
        ]),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// KUIS PLAY SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class _KuisPlayScreen extends StatefulWidget {
  final KuisLevel level;
  const _KuisPlayScreen({required this.level});

  @override
  State<_KuisPlayScreen> createState() => _KuisPlayScreenState();
}

class _KuisPlayScreenState extends State<_KuisPlayScreen> {
  late final List<KuisQuestion> _questions;
  int _current  = 0;
  int _score    = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.level.questions;
  }

  void _pickAnswer(int idx) {
    if (_answered) return;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == _questions[_current].correctIndex) _score++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      KuisStorage.saveResult(widget.level.index, _score, _questions.length);
      setState(() => _finished = true);
    }
  }

  void _restart() => setState(() {
        _current  = 0;
        _score    = 0;
        _selected = null;
        _answered = false;
        _finished = false;
      });

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: _finished
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.level.emoji,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(widget.level.title,
                    style: AppText.heading(14)),
                Text('  ${_current + 1}/${_questions.length}',
                    style: AppText.body(13, color: AppColors.grey500)),
              ]),
        actions: _finished
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text('$_score',
                            style: AppText.label(13,
                                color: AppColors.navyDeep)),
                      ]),
                    ),
                  ),
                ),
              ],
      ),
      body: _finished
          ? _buildResult(mobile)
          : _buildQuestion(mobile),
    );
  }

  Widget _buildQuestion(bool mobile) {
    final q = _questions[_current];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  mobile ? 20 : 40, 8, mobile ? 20 : 40, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (_current + 1) / _questions.length,
                  backgroundColor: AppColors.grey100,
                  color: widget.level.color,
                  minHeight: 6,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  mobile ? 20 : 40,
                  20,
                  mobile ? 20 : 40,
                  mobile ? 100 : 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.level.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.level.emoji}  Level ${widget.level.index + 1} — ${widget.level.title}',
                          style: AppText.label(12,
                              color: widget.level.color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navyDeep.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.question,
                              style: AppText.heading(mobile ? 15 : 17)),
                          const SizedBox(height: 20),
                          ...q.options.asMap().entries.map(
                                (e) => _OptionTile(
                                  label:
                                      String.fromCharCode(65 + e.key),
                                  text: e.value,
                                  state: _optionState(
                                      e.key, q.correctIndex),
                                  onTap: () => _pickAnswer(e.key),
                                ),
                              ),
                          if (_answered) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _selected == q.correctIndex
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFBE9E7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _selected == q.correctIndex
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: _selected == q.correctIndex
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFE53935),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(q.explanation,
                                        style: AppText.body(13)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_answered)
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.level.color,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          _current < _questions.length - 1
                              ? 'Soal Berikutnya →'
                              : 'Lihat Hasil 🎉',
                          style: AppText.heading(14,
                              color: AppColors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OptionState _optionState(int idx, int correct) {
    if (!_answered) return _OptionState.normal;
    if (idx == correct) return _OptionState.correct;
    if (idx == _selected) return _OptionState.wrong;
    return _OptionState.dim;
  }

  Widget _buildResult(bool mobile) {
    final pct = (_score / _questions.length * 100).round();
    final passed = pct >= 60;
    final perfect = _score == _questions.length;
    final isLastLevel = widget.level.index == _levelData.length - 1;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            mobile ? 24 : 40,
            24,
            mobile ? 24 : 40,
            mobile ? 40 : 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(perfect ? '🏆' : passed ? '🌟' : '📚',
                  style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                perfect ? 'Sempurna!' : passed ? 'Bagus!' : 'Hampir!',
                style: AppText.display(30, color: AppColors.navyDeep),
              ),
              const SizedBox(height: 6),
              Text(
                'Kamu menjawab $_score dari ${_questions.length} soal dengan benar',
                style: AppText.body(14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.level.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.level.color.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$pct%',
                        style: AppText.heading(34,
                            color: AppColors.white)),
                    Text('Skor',
                        style: AppText.body(12,
                            color: AppColors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.level.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: widget.level.color.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Text(widget.level.emoji,
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${widget.level.index + 1} — ${widget.level.title}',
                            style: AppText.label(11,
                                color: AppColors.grey500)),
                        const SizedBox(height: 3),
                        Text(
                          passed
                              ? perfect
                                  ? 'Nilai sempurna! Luar biasa! 🎉'
                                  : 'Level berhasil diselesaikan!'
                              : 'Perlu ${((_questions.length * 0.6).ceil()) - _score} jawaban lagi untuk lulus',
                          style: AppText.heading(13,
                              color: AppColors.navyDeep),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              if (passed && !isLastLevel) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.lock_open_rounded,
                        color: Color(0xFF4CAF50), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Level "${_levelData[widget.level.index + 1].title}" terbuka!',
                        style: AppText.body(13).copyWith(
                            color: const Color(0xFF2E7D32)),
                      ),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restart,
                    child: const Text('Coba Lagi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyDeep,
                    ),
                    child: const Text('Selesai'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OptionState { normal, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  final String label, text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, border, textC, labelBg;
    switch (state) {
      case _OptionState.correct:
        bg      = const Color(0xFFE8F5E9);
        border  = const Color(0xFF4CAF50);
        textC   = const Color(0xFF2E7D32);
        labelBg = const Color(0xFF4CAF50);
        break;
      case _OptionState.wrong:
        bg      = const Color(0xFFFBE9E7);
        border  = const Color(0xFFE53935);
        textC   = const Color(0xFFC62828);
        labelBg = const Color(0xFFE53935);
        break;
      case _OptionState.dim:
        bg      = AppColors.grey100;
        border  = AppColors.grey300;
        textC   = AppColors.grey500;
        labelBg = AppColors.grey300;
        break;
      default:
        bg      = AppColors.offWhite;
        border  = AppColors.grey300;
        textC   = AppColors.navyDeep;
        labelBg = AppColors.navyMid;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: labelBg, shape: BoxShape.circle),
            child: Center(
              child: Text(label,
                  style: AppText.label(12, color: AppColors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppText.body(14, color: textC)
                    .copyWith(fontWeight: FontWeight.w500)),
          ),
          if (state == _OptionState.correct)
            const Icon(Icons.check_rounded, color: Color(0xFF4CAF50), size: 18),
          if (state == _OptionState.wrong)
            const Icon(Icons.close_rounded, color: Color(0xFFE53935), size: 18),
        ]),
      ),
    );
  }
}