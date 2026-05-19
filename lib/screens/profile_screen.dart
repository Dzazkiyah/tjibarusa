// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/auth_service.dart';
import 'checkin_screen.dart';
import 'kuis_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _selectedGender = 'cewe'; // 'cewe' or 'cowo'
  bool _showGenderPicker = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadGenderPreference();
  }

  Future<void> _loadGenderPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGender = prefs.getString('user_gender') ?? 'cewe';
    });
  }

  Future<void> _saveGenderPreference(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_gender', gender);
    setState(() {
      _selectedGender = gender;
      _showGenderPicker = false;
    });
  }

  Future<void> _loadUserData() async {
    final data = await AuthService.getUserData();
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.navyMid),
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()));
                break;
              case 1:
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const KuisScreen()));
                break;
              case 2:
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const CheckInScreen()));
                break;
              case 3:
                break;
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: FutureBuilder<List<CheckInRecord>>(
        future: CheckInStorage.load(),
        builder: (context, snapshot) {
          final history = snapshot.data ?? [];
          final visits = history.where((r) => r.fotoUploaded).length;
          final award = currentAward(visits);
          final next = nextAward(visits);
          final kuisScore = KuisStorage.lastScore;
          final kuisTotal = KuisStorage.totalPlayed;
          final userName = AuthService.currentUser?.displayName ?? 'Penjelajah Cibarusah';
          final userEmail = AuthService.currentUser?.email ?? 'penjelajah@cibarusah.id';

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: AppColors.navyDeep,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_rounded,
                                    color: AppColors.white, size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              Text('Profil',
                                  style: AppText.heading(18,
                                      color: AppColors.white)),
                              const Spacer(),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Avatar dengan tombol pilih gender
                        GestureDetector(
                          onTap: () => setState(() => _showGenderPicker = !_showGenderPicker),
                          child: Container(
                            width: 88, height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.navyLight,
                              border: Border.all(color: AppColors.white, width: 3),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                _selectedGender == 'cewe' 
                                    ? 'assets/images/wening.png' 
                                    : 'assets/images/galih.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.emoji_emotions_rounded,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Gender picker buttons
                        if (_showGenderPicker)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _GenderButton(
                                  label: '👧 Perempuan',
                                  isSelected: _selectedGender == 'cewe',
                                  onTap: () => _saveGenderPreference('cewe'),
                                ),
                                const SizedBox(width: 12),
                                _GenderButton(
                                  label: '👦 Laki-laki',
                                  isSelected: _selectedGender == 'cowo',
                                  onTap: () => _saveGenderPreference('cowo'),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),
                        Text(userName,
                            style: AppText.heading(18, color: AppColors.white)),
                        const SizedBox(height: 4),
                        Text(userEmail,
                            style: AppText.body(13,
                                color: AppColors.white.withOpacity(0.6))),
                        const SizedBox(height: 20),

                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.navyMid.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(
                                value: '$visits',
                                label: 'Kunjungan',
                                icon: Icons.place_rounded,
                              ),
                              _divider(),
                              _StatItem(
                                value: '$kuisTotal',
                                label: 'Kuis Dimainkan',
                                icon: Icons.quiz_rounded,
                              ),
                              _divider(),
                              _StatItem(
                                value: kuisTotal > 0
                                    ? '${(kuisScore / (kuisTotal * 5) * 100).round()}%'
                                    : '-',
                                label: 'Akurasi',
                                icon: Icons.military_tech_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(mobile ? 20 : 40),
                  child: mobile
                      ? _mobileBody(context, visits, history, award, next,
                          kuisScore, kuisTotal)
                      : _desktopBody(context, visits, history, award, next,
                          kuisScore, kuisTotal),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const KuisScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const CheckInScreen()));
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }

  Widget _divider() =>
      Container(height: 36, width: 1, color: AppColors.white.withOpacity(0.2));

  Widget _mobileBody(
    BuildContext ctx, int visits, List<CheckInRecord> history,
    AwardTier award, AwardTier? next, int score, int total,
  ) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AwardCard(visits: visits, award: award, next: next),
          const SizedBox(height: 24),
          _BadgeGrid(visits: visits),
          const SizedBox(height: 24),
          _CheckInHistory(history: history),
          const SizedBox(height: 24),
          _KuisHistory(score: score, total: total),
          const SizedBox(height: 24),
          _LogoutButton(onLogout: _logout),
          const SizedBox(height: 32),
        ],
      );

  Widget _desktopBody(
    BuildContext ctx, int visits, List<CheckInRecord> history,
    AwardTier award, AwardTier? next, int score, int total,
  ) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(children: [
              _AwardCard(visits: visits, award: award, next: next),
              const SizedBox(height: 24),
              _BadgeGrid(visits: visits),
            ]),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(children: [
              _CheckInHistory(history: history),
              const SizedBox(height: 24),
              _KuisHistory(score: score, total: total),
              const SizedBox(height: 24),
              _LogoutButton(onLogout: _logout),
            ]),
          ),
        ],
      );
}

// Gender Button Widget
class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.white.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: AppText.label(12, color: isSelected ? AppColors.navyDeep : AppColors.white),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(height: 4),
          Text(value, style: AppText.heading(20, color: AppColors.white)),
          Text(label,
              style: AppText.body(10,
                  color: AppColors.white.withOpacity(0.6))),
        ],
      );
}

// ─── Award Card ───────────────────────────────────────────────────────────────
class _AwardCard extends StatelessWidget {
  final int visits;
  final AwardTier award;
  final AwardTier? next;
  const _AwardCard(
      {required this.visits, required this.award, this.next});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
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
            Text(award.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(award.title,
                style: AppText.heading(18, color: AppColors.white)),
            Text(award.desc,
                style: AppText.body(12,
                    color: AppColors.white.withOpacity(0.65))),
            if (next != null) ...[
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: visits / next!.minVisit,
                      backgroundColor: AppColors.white.withOpacity(0.15),
                      color: AppColors.gold,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$visits/${next!.minVisit}',
                    style: AppText.body(11,
                        color: AppColors.white.withOpacity(0.6))),
              ]),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${next!.minVisit - visits} kunjungan lagi → "${next!.title}"',
                  style: AppText.body(11,
                      color: AppColors.white.withOpacity(0.55)),
                ),
              ),
            ],
          ],
        ),
      );
}

// ─── Badge Grid ───────────────────────────────────────────────────────────────
class _BadgeGrid extends StatelessWidget {
  final int visits;
  const _BadgeGrid({required this.visits});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.navyDeep.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Koleksi Badge', style: AppText.heading(16)),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: kAwards.map((a) {
                final earned = visits >= a.minVisit;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: earned
                        ? a.color.withOpacity(0.1)
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: earned
                          ? a.color.withOpacity(0.4)
                          : AppColors.grey300,
                    ),
                  ),
                  child: Row(children: [
                    Text(a.emoji,
                        style: TextStyle(
                            fontSize: 22,
                            color: earned ? null : Colors.black26)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(a.title,
                              style: AppText.label(11,
                                  color: earned
                                      ? AppColors.navyDeep
                                      : AppColors.grey300),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('${a.minVisit} kunjungan',
                              style: AppText.body(9,
                                  color: earned
                                      ? AppColors.grey500
                                      : AppColors.grey300)),
                        ],
                      ),
                    ),
                    if (earned)
                      Icon(Icons.check_circle_rounded,
                          color: a.color, size: 14),
                  ]),
                );
              }).toList(),
            ),
          ],
        ),
      );
}

// ─── Check-in History ─────────────────────────────────────────────────────────
class _CheckInHistory extends StatelessWidget {
  final List<CheckInRecord> history;
  const _CheckInHistory({required this.history});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.navyDeep.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Riwayat Kunjungan', style: AppText.heading(16)),
              const Spacer(),
              Text('${history.length} tempat',
                  style: AppText.body(12, color: AppColors.navyMid)),
            ]),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('Belum ada kunjungan',
                      style: AppText.body(13, color: AppColors.grey500)),
                ),
              )
            else
              ...history.take(3).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetImg(r.wisataImage, w: 48, h: 48),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.wisataName,
                                style: AppText.heading(13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(
                              '${r.date.day}/${r.date.month}/${r.date.year}',
                              style: AppText.body(11),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        r.fotoUploaded
                            ? Icons.check_circle_rounded
                            : Icons.camera_alt_rounded,
                        color: r.fotoUploaded
                            ? const Color(0xFF4CAF50)
                            : AppColors.grey300,
                        size: 18,
                      ),
                    ]),
                  )),
          ],
        ),
      );
}

// ─── Kuis History ─────────────────────────────────────────────────────────────
class _KuisHistory extends StatelessWidget {
  final int score, total;
  const _KuisHistory({required this.score, required this.total});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.navyDeep.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistik Kuis', style: AppText.heading(16)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _KuisStat(
                    value: '$total',
                    label: 'Dimainkan',
                    color: AppColors.navyMid),
                _KuisStat(
                    value: '$score',
                    label: 'Total Benar',
                    color: const Color(0xFF4CAF50)),
                _KuisStat(
                  value: total > 0
                      ? '${(score / (total * 5) * 100).round()}%'
                      : '-',
                  label: 'Akurasi',
                  color: AppColors.gold,
                ),
              ],
            ),
            if (total == 0) ...[
              const SizedBox(height: 12),
              Center(
                child: Text('Belum pernah main kuis',
                    style: AppText.body(12, color: AppColors.grey500)),
              ),
            ],
          ],
        ),
      );
}

class _KuisStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _KuisStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: AppText.heading(28, color: color)),
          Text(label, style: AppText.body(11)),
        ],
      );
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.navyDeep.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
          ),
          title: Text('Logout',
              style: AppText.body(14, color: Colors.red)
                  .copyWith(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
          onTap: onLogout,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
}