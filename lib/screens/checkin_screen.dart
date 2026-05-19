// lib/screens/checkin_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'kuis_screen.dart';
import 'profile_screen.dart';

// ════════════════════════════════════════════════════════════════════════════════
// MODEL
// ════════════════════════════════════════════════════════════════════════════════
class CheckInRecord {
  final String wisataId;
  final String wisataName;
  final String wisataImage;
  final DateTime date;
  final String? localPhotoPath;

  const CheckInRecord({
    required this.wisataId,
    required this.wisataName,
    required this.wisataImage,
    required this.date,
    this.localPhotoPath,
  });

  Map<String, dynamic> toJson() => {
        'wisataId': wisataId,
        'wisataName': wisataName,
        'wisataImage': wisataImage,
        'date': date.toIso8601String(),
        'localPhotoPath': localPhotoPath,
      };

  factory CheckInRecord.fromJson(Map<String, dynamic> j) => CheckInRecord(
        wisataId: j['wisataId'],
        wisataName: j['wisataName'],
        wisataImage: j['wisataImage'],
        date: DateTime.parse(j['date']),
        localPhotoPath: j['localPhotoPath'],
      );

  bool get fotoUploaded => localPhotoPath != null;

  CheckInRecord copyWith({String? localPhotoPath}) => CheckInRecord(
        wisataId: wisataId,
        wisataName: wisataName,
        wisataImage: wisataImage,
        date: date,
        localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// AWARD TIERS
// ════════════════════════════════════════════════════════════════════════════════
class AwardTier {
  final String title, emoji, desc;
  final int minVisit;
  final Color color;
  const AwardTier({
    required this.title,
    required this.emoji,
    required this.desc,
    required this.minVisit,
    required this.color,
  });
}

const List<AwardTier> kAwards = [
  AwardTier(title: 'Penjelajah Baru', emoji: '🌱', minVisit: 1,
      desc: 'Kunjungi 1 tempat wisata', color: Color(0xFF4CAF50)),
  AwardTier(title: 'Petualang Muda', emoji: '🗺️', minVisit: 3,
      desc: 'Kunjungi 3 tempat wisata', color: Color(0xFF2196F3)),
  AwardTier(title: 'Penjaga Warisan', emoji: '🏛️', minVisit: 5,
      desc: 'Kunjungi 5 tempat wisata', color: Color(0xFFFFB300)),
  AwardTier(title: 'Duta Cibarusah', emoji: '🏆', minVisit: 8,
      desc: 'Kunjungi 8 tempat wisata', color: Color(0xFFE91E63)),
];

AwardTier currentAward(int v) {
  AwardTier r = kAwards.first;
  for (final a in kAwards) {
    if (v >= a.minVisit) r = a;
  }
  return r;
}

AwardTier? nextAward(int v) {
  for (final a in kAwards) {
    if (v < a.minVisit) return a;
  }
  return null;
}

// ════════════════════════════════════════════════════════════════════════════════
// LOCAL STORAGE HELPER
// ════════════════════════════════════════════════════════════════════════════════
class CheckInStorage {
  static const _key = 'checkin_records';

  static Future<List<CheckInRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => CheckInRecord.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> save(List<CheckInRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, records.map((r) => jsonEncode(r.toJson())).toList());
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// CHECKPOINT SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<CheckInRecord> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final records = await CheckInStorage.load();
    if (mounted) setState(() {
      _history = records;
      _loading = false;
    });
  }

  Future<void> _saveHistory() => CheckInStorage.save(_history);

  int get _visitCount => _history.where((r) => r.fotoUploaded).length;

  void _doCheckIn(WisataModel wisata) {
    final already = _history.any((r) => r.wisataId == wisata.id);
    if (already) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sudah check point di ${wisata.name}!'),
        backgroundColor: AppColors.navyMid,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => _CheckInDialog(
        wisata: wisata,
        onConfirm: () async {
          final record = CheckInRecord(
            wisataId: wisata.id,
            wisataName: wisata.name,
            wisataImage: wisata.imageUrl,
            date: DateTime.now(),
          );
          setState(() => _history.insert(0, record));
          await _saveHistory();
          if (!mounted) return;
          Navigator.pop(context);
          _tab.animateTo(2);
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) _openUploadFoto(record);
        },
      ),
    );
  }

  void _openUploadFoto(CheckInRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadFotoSheet(
        record: record,
        onUploaded: (path) async {
          final idx = _history.indexWhere((r) => r.wisataId == record.wisataId);
          if (idx != -1) {
            setState(() => _history[idx] = record.copyWith(localPhotoPath: path));
            await _saveHistory();
          }
          if (!mounted) return;
          Navigator.pop(context);
          _showAwardIfEarned();
        },
      ),
    );
  }

  void _showAwardIfEarned() {
    final visits = _visitCount;
    final justEarned = kAwards.any((a) => a.minVisit == visits);
    if (!justEarned) return;
    showDialog(
      context: context,
      builder: (_) => _AwardDialog(award: currentAward(visits)),
    );
  }

  void _deleteRecord(CheckInRecord record) async {
    setState(() {
      _history.removeWhere((r) => r.wisataId == record.wisataId);
    });
    await _saveHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kunjungan ke ${record.wisataName} dihapus'),
        backgroundColor: AppColors.navyMid,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text('Check Point Wisata',
            style: AppText.heading(18, color: AppColors.white)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.45),
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Checkpoint'),
            Tab(text: 'Semua Lokasi'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navyMid))
          : TabBarView(
              controller: _tab,
              children: [
                _CheckpointTab(
                  history: _history,
                  onCheckIn: _doCheckIn,
                  onUploadFoto: _openUploadFoto,
                ),
                _SemuaLokasiTab(
                  history: _history,
                  onCheckIn: _doCheckIn,
                ),
                _RiwayatTab(
                  history: _history,
                  visitCount: _visitCount,
                  onUploadFoto: _openUploadFoto,
                  onDeleteRecord: _deleteRecord,
                ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
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

// ════════════════════════════════════════════════════════════════════════════════
// TAB 1 — CHECKPOINT
// ════════════════════════════════════════════════════════════════════════════════
class _CheckpointTab extends StatelessWidget {
  final List<CheckInRecord> history;
  final void Function(WisataModel) onCheckIn;
  final void Function(CheckInRecord) onUploadFoto;

  const _CheckpointTab({
    required this.history,
    required this.onCheckIn,
    required this.onUploadFoto,
  });

  @override
  Widget build(BuildContext context) {
    final visitCount = history.where((r) => r.fotoUploaded).length;
    final award = currentAward(visitCount);
    final next = nextAward(visitCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navyDeep, AppColors.navyMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Text(award.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(award.title,
                        style: AppText.heading(18, color: AppColors.white)),
                    const SizedBox(height: 4),
                    Text('$visitCount tempat diverifikasi',
                        style: AppText.body(12,
                            color: AppColors.white.withOpacity(0.65))),
                    if (next != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: visitCount / next.minVisit,
                          backgroundColor: AppColors.white.withOpacity(0.15),
                          color: AppColors.gold,
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${next.minVisit - visitCount} lagi → ${next.emoji} ${next.title}',
                        style: AppText.body(10,
                            color: AppColors.white.withOpacity(0.55)),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('🎉 Semua badge terkumpul!',
                            style: AppText.label(12, color: AppColors.gold)),
                      ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Checkpoint Wisata', style: AppText.heading(16)),
          const SizedBox(height: 4),
          Text('Kunjungi & upload foto untuk unlock checkpoint',
              style: AppText.body(12, color: AppColors.grey500)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: DummyData.wisata.length,
            itemBuilder: (_, i) {
              final wisata = DummyData.wisata[i];
              final record = history.firstWhere(
                (r) => r.wisataId == wisata.id,
                orElse: () => CheckInRecord(
                  wisataId: '',
                  wisataName: '',
                  wisataImage: '',
                  date: DateTime.now(),
                ),
              );
              final checkedIn = record.wisataId.isNotEmpty;
              final verified = record.fotoUploaded;
              return _CheckpointCard(
                wisata: wisata,
                number: i + 1,
                checkedIn: checkedIn,
                verified: verified,
                localPhotoPath: record.localPhotoPath,
                onTap: () {
                  if (!checkedIn) {
                    onCheckIn(wisata);
                  } else if (!verified) {
                    onUploadFoto(record);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckpointCard extends StatelessWidget {
  final WisataModel wisata;
  final int number;
  final bool checkedIn, verified;
  final String? localPhotoPath;
  final VoidCallback onTap;

  const _CheckpointCard({
    required this.wisata,
    required this.number,
    required this.checkedIn,
    required this.verified,
    required this.onTap,
    this.localPhotoPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: verified
                  ? AppColors.gold.withOpacity(0.25)
                  : AppColors.navyDeep.withOpacity(0.08),
              blurRadius: verified ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: verified
                ? AppColors.gold
                : checkedIn
                    ? AppColors.navyMid.withOpacity(0.3)
                    : Colors.transparent,
            width: verified ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: verified && localPhotoPath != null
                  ? Image.file(File(localPhotoPath!), fit: BoxFit.cover)
                  : ColorFiltered(
                      colorFilter: checkedIn
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.saturation)
                          : const ColorFilter.matrix([
                              0.2, 0.2, 0.2, 0, 0,
                              0.2, 0.2, 0.2, 0, 0,
                              0.2, 0.2, 0.2, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: NetImg(wisata.imageUrl),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: verified
                        ? [Colors.black12, Colors.black54]
                        : checkedIn
                            ? [Colors.black26, Colors.black54]
                            : [Colors.black54, Colors.black87],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: verified
                      ? AppColors.gold
                      : checkedIn
                          ? AppColors.navyMid
                          : Colors.black45,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '#$number',
                  style: AppText.label(10, color: AppColors.white),
                ),
              ),
            ),
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: verified
                      ? AppColors.gold
                      : checkedIn
                          ? AppColors.navyMid
                          : Colors.black45,
                ),
                child: Icon(
                  verified
                      ? Icons.star_rounded
                      : checkedIn
                          ? Icons.camera_alt_rounded
                          : Icons.lock_rounded,
                  size: 15,
                  color: AppColors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      wisata.name,
                      style: AppText.heading(12, color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: verified
                            ? AppColors.gold.withOpacity(0.9)
                            : checkedIn
                                ? AppColors.navyMid.withOpacity(0.9)
                                : Colors.white24,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        verified
                            ? '✓ Terverifikasi'
                            : checkedIn
                                ? '📷 Upload foto'
                                : '🔒 Belum dikunjungi',
                        style: AppText.body(9, color: AppColors.white)
                            .copyWith(fontWeight: FontWeight.w600),
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
}

// ════════════════════════════════════════════════════════════════════════════════
// TAB 2 — SEMUA LOKASI
// ════════════════════════════════════════════════════════════════════════════════
class _SemuaLokasiTab extends StatelessWidget {
  final List<CheckInRecord> history;
  final void Function(WisataModel) onCheckIn;

  const _SemuaLokasiTab({required this.history, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.navyMid.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navyMid.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.navyMid, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pilih lokasi, check point, lalu upload foto sebagai bukti kunjungan.',
                style: AppText.body(12),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        ...DummyData.wisata.map((w) {
          final record = history.firstWhere(
            (r) => r.wisataId == w.id,
            orElse: () => CheckInRecord(
              wisataId: '',
              wisataName: '',
              wisataImage: '',
              date: DateTime.now(),
            ),
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _LokasiCard(
              wisata: w,
              record: record.wisataId.isNotEmpty ? record : null,
              onCheckIn: onCheckIn,
            ),
          );
        }),
      ],
    );
  }
}

class _LokasiCard extends StatelessWidget {
  final WisataModel wisata;
  final CheckInRecord? record;
  final void Function(WisataModel) onCheckIn;

  const _LokasiCard({
    required this.wisata,
    required this.record,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.navyDeep.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          SizedBox(width: 100, height: 100, child: NetImg(wisata.imageUrl)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wisata.name, style: AppText.heading(14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.grey500),
                    const SizedBox(width: 2),
                    Expanded(child: Text(wisata.location,
                        style: AppText.body(11), maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 8),
                  if (record?.fotoUploaded == true)
                    _pill('✓ Terverifikasi', const Color(0xFF4CAF50))
                  else if (record != null)
                    _pill('📷 Perlu upload foto', AppColors.gold)
                  else
                    ElevatedButton.icon(
                      onPressed: () => onCheckIn(wisata),
                      icon: const Icon(Icons.add_location_alt_rounded, size: 14),
                      label: const Text('Check Point'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        textStyle: AppText.label(12, color: AppColors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]),
      );

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: AppText.label(11, color: color)),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// TAB 3 — RIWAYAT (dengan preview & hapus)
// ════════════════════════════════════════════════════════════════════════════════
class _RiwayatTab extends StatelessWidget {
  final List<CheckInRecord> history;
  final int visitCount;
  final void Function(CheckInRecord) onUploadFoto;
  final void Function(CheckInRecord) onDeleteRecord;

  const _RiwayatTab({
    required this.history,
    required this.visitCount,
    required this.onUploadFoto,
    required this.onDeleteRecord,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: kAwards.map((a) {
            final earned = visitCount >= a.minVisit;
            return Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: earned
                      ? a.color.withOpacity(0.15)
                      : AppColors.grey100,
                  border: Border.all(
                    color: earned ? a.color : AppColors.grey200,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(a.emoji,
                      style: TextStyle(
                          fontSize: earned ? 24 : 18,
                          color: earned ? null : Colors.transparent)),
                ),
              ),
              const SizedBox(height: 5),
              Text(a.title.split(' ').first,
                  style: AppText.body(9,
                      color: earned ? AppColors.navyDeep : AppColors.grey300)),
            ]);
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Riwayat Kunjungan', style: AppText.heading(16)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(children: [
                const Icon(Icons.map_outlined, size: 48, color: AppColors.grey300),
                const SizedBox(height: 12),
                Text('Belum ada kunjungan',
                    style: AppText.body(14, color: AppColors.grey500)),
                const SizedBox(height: 4),
                Text('Check point ke tempat wisata dulu!',
                    style: AppText.body(12, color: AppColors.grey300)),
              ]),
            ),
          )
        else
          ...history.map((r) => _RiwayatCard(
                record: r,
                onUpload: r.fotoUploaded ? null : () => onUploadFoto(r),
                onDelete: () => onDeleteRecord(r),
              )),
      ],
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final CheckInRecord record;
  final VoidCallback? onUpload;
  final VoidCallback onDelete;

  const _RiwayatCard({
    required this.record,
    this.onUpload,
    required this.onDelete,
  });

  void _showPhotoPreview(BuildContext context) {
    if (record.localPhotoPath == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(record.localPhotoPath!),
                fit: BoxFit.contain,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kunjungan ke "${record.wisataName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (record.fotoUploaded) {
          _showPhotoPreview(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDeep.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (record.fotoUploaded) {
                  _showPhotoPreview(context);
                }
              },
              child: SizedBox(
                width: 90,
                height: 90,
                child: record.localPhotoPath != null
                    ? Image.file(File(record.localPhotoPath!), fit: BoxFit.cover)
                    : NetImg(record.wisataImage, w: 90, h: 90),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.wisataName,
                      style: AppText.heading(14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.date.day}/${record.date.month}/${record.date.year}',
                      style: AppText.body(11, color: AppColors.grey500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (record.fotoUploaded)
                          GestureDetector(
                            onTap: () => _showPhotoPreview(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      color: Color(0xFF4CAF50), size: 12),
                                  const SizedBox(width: 4),
                                  Text('Terverifikasi',
                                      style: AppText.label(10,
                                          color: const Color(0xFF4CAF50))),
                                ],
                              ),
                            ),
                          )
                        else if (onUpload != null)
                          GestureDetector(
                            onTap: onUpload,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: AppColors.gold.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt_rounded,
                                      color: AppColors.gold, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Upload Foto',
                                      style: AppText.label(10,
                                          color: AppColors.gold)),
                                ],
                              ),
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
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
}

// ════════════════════════════════════════════════════════════════════════════════
// DIALOG CHECK POINT KONFIRMASI
// ════════════════════════════════════════════════════════════════════════════════
class _CheckInDialog extends StatelessWidget {
  final WisataModel wisata;
  final VoidCallback onConfirm;

  const _CheckInDialog({required this.wisata, required this.onConfirm});

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: NetImg(wisata.imageUrl, h: 150, w: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const Icon(Icons.add_location_alt_rounded,
                    color: AppColors.navyMid, size: 28),
                const SizedBox(height: 8),
                Text('Check point di sini?', style: AppText.heading(17)),
                const SizedBox(height: 4),
                Text(wisata.name,
                    style: AppText.heading(14, color: AppColors.navyMid),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(wisata.location,
                    style: AppText.body(12, color: AppColors.grey500),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Setelah check point, upload foto di lokasi ini sebagai bukti kunjungan.',
                  style: AppText.body(12, color: AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      child: const Text('Ya, Check Point!'),
                    ),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET UPLOAD FOTO
// ════════════════════════════════════════════════════════════════════════════════
class _UploadFotoSheet extends StatefulWidget {
  final CheckInRecord record;
  final void Function(String path) onUploaded;

  const _UploadFotoSheet({required this.record, required this.onUploaded});

  @override
  State<_UploadFotoSheet> createState() => _UploadFotoSheetState();
}

class _UploadFotoSheetState extends State<_UploadFotoSheet> {
  final _picker = ImagePicker();
  String? _selectedPath;
  bool _uploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked != null && mounted) {
      setState(() => _selectedPath = picked.path);
    }
  }

  Future<void> _confirm() async {
    if (_selectedPath == null) return;
    setState(() => _uploading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) widget.onUploaded(_selectedPath!);
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Upload Foto Kunjungan', style: AppText.heading(17)),
            const SizedBox(height: 4),
            Text(widget.record.wisataName,
                style: AppText.heading(13, color: AppColors.navyMid)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey300),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedPath != null
                    ? Image.file(File(_selectedPath!), fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_rounded,
                              color: AppColors.grey400, size: 40),
                          const SizedBox(height: 10),
                          Text('Ketuk untuk pilih dari galeri',
                              style: AppText.body(13, color: AppColors.grey500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                  label: const Text('Galeri'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                  label: const Text('Kamera'),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedPath == null || _uploading) ? null : _confirm,
                child: _uploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppColors.white))
                    : const Text('Konfirmasi & Simpan'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Nanti saja',
                  style: AppText.body(13, color: AppColors.grey500)),
            ),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// DIALOG AWARD
// ════════════════════════════════════════════════════════════════════════════════
class _AwardDialog extends StatelessWidget {
  final AwardTier award;

  const _AwardDialog({required this.award});

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: award.color.withOpacity(0.15),
                  border: Border.all(color: award.color, width: 3),
                ),
                child: Center(
                    child: Text(award.emoji,
                        style: const TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 16),
              Text('🎉 Badge Baru!',
                  style: AppText.heading(13, color: AppColors.grey500)),
              const SizedBox(height: 6),
              Text(award.title,
                  style: AppText.display(22, color: AppColors.navyDeep)),
              const SizedBox(height: 8),
              Text(award.desc,
                  style: AppText.body(13), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
                child: const Text('Keren! 🎊'),
              ),
            ],
          ),
        ),
      );
}