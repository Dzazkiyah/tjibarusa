// lib/screens/detail_wisata_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/shared_widgets.dart';

class DetailWisataScreen extends StatefulWidget {
  final WisataModel wisata;
  const DetailWisataScreen({super.key, required this.wisata});

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen> {
  List<ReviewModel> _userReviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final allReviews = await ReviewStorage.getAllReviews();
    setState(() {
      _userReviews = allReviews[widget.wisata.id] ?? [];
    });
  }

  Future<void> _addReview(String comment, double rating, String userName) async {
    final newReview = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName,
      avatarInitial: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
      comment: comment,
      rating: rating,
      date: DateTime.now(),
    );

    // Langsung update state biar review langsung tampil
    setState(() {
      _userReviews.insert(0, newReview);
    });
    
    // Simpan ke storage
    await ReviewStorage.addReview(widget.wisata.id, newReview);
  }

  Future<void> _deleteReview(String reviewId) async {
    await ReviewStorage.deleteReview(widget.wisata.id, reviewId);
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final screenH = MediaQuery.of(context).size.height;

    final allReviews = [...widget.wisata.reviews, ..._userReviews];
    final avgRating = allReviews.isEmpty
        ? widget.wisata.rating
        : (allReviews.map((r) => r.rating).reduce((a, b) => a + b) / allReviews.length);
    final avgRatingDisplay = (avgRating * 10).round() / 10;
    final totalReviews = allReviews.length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image
            Stack(
              children: [
                NetImg(widget.wisata.imageUrl,
                    h: screenH * (mobile ? 0.45 : 0.55),
                    w: double.infinity),
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.offWhite],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _BackBtn(onTap: () => Navigator.pop(context)),
                  ),
                ),
              ],
            ),

            CW(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Text(
                    widget.wisata.name,
                    style: AppText.display(mobile ? 28 : 36, color: AppColors.navyDeep),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      StarRating(avgRatingDisplay, size: 16),
                      const SizedBox(width: 8),
                      Text('$avgRatingDisplay',
                          style: AppText.heading(16, color: AppColors.navyDeep)),
                      const SizedBox(width: 6),
                      Text('($totalReviews ulasan)',
                          style: AppText.body(12, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.wisata.tags.map((t) => PillTag(t)).toList(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.navyMid),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.wisata.location,
                          style: AppText.body(13, color: AppColors.navyMid)
                              .copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.navyMid),
                      const SizedBox(width: 4),
                      Text(
                        'Jam Buka: ${widget.wisata.jamBuka}',
                        style: AppText.body(13, color: AppColors.navyMid)
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.navyMid),
                      const SizedBox(width: 4),
                      Text(
                        'Tiket: ${widget.wisata.hargaTiket}',
                        style: AppText.body(13, color: AppColors.navyMid)
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.wisata.shortDesc,
                    style: AppText.body(15).copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  mobile ? _mobileContent(context) : _desktopContent(context),

                  const SizedBox(height: 40),

                  // Review section
                  _ReviewSection(
                    wisata: widget.wisata,
                    userReviews: _userReviews,
                    avgRating: avgRatingDisplay,
                    totalReviews: totalReviews,
                    onAddReview: _addReview,
                    onDeleteReview: _deleteReview,
                    onRefresh: _loadReviews,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileContent(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: NetImg(widget.wisata.imageUrl, h: 200, w: double.infinity),
          ),
          const SizedBox(height: 20),
          _fullDescText(),
          const SizedBox(height: 16),
          _mapsBtn(),
        ],
      );

  Widget _desktopContent(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: NetImg(widget.wisata.imageUrl, h: 280, w: 300),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fullDescText(),
                const SizedBox(height: 20),
                _mapsBtn(),
              ],
            ),
          ),
        ],
      );

  Widget _fullDescText() => Text(
        widget.wisata.fullDesc,
        style: AppText.body(14).copyWith(height: 1.8),
      );

  Widget _mapsBtn() => ElevatedButton.icon(
        onPressed: () => launchUrl(Uri.parse(widget.wisata.mapsUrl)),
        icon: const Icon(Icons.map_rounded, size: 16),
        label: const Text('Jelajahi Maps'),
      );
}

// ─── Review Section ───────────────────────────────────────────────────────────
class _ReviewSection extends StatefulWidget {
  final WisataModel wisata;
  final List<ReviewModel> userReviews;
  final double avgRating;
  final int totalReviews;
  final Function(String, double, String) onAddReview;
  final Function(String) onDeleteReview;
  final VoidCallback onRefresh;

  const _ReviewSection({
    required this.wisata,
    required this.userReviews,
    required this.avgRating,
    required this.totalReviews,
    required this.onAddReview,
    required this.onDeleteReview,
    required this.onRefresh,
  });

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _showForm = false;

  void _submitReview() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama Anda')),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan komentar Anda')),
      );
      return;
    }

    widget.onAddReview(_commentController.text, _rating, _nameController.text);
    _nameController.clear();
    _commentController.clear();
    setState(() {
      _rating = 5.0;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final allReviews = [...widget.wisata.reviews, ...widget.userReviews];

    return mobile ? _mobileLayout(allReviews) : _desktopLayout(allReviews, context);
  }

  Widget _desktopLayout(List<ReviewModel> reviews, BuildContext ctx) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _reviewList(reviews)),
          const SizedBox(width: 40),
          Expanded(child: _descCard(ctx)),
        ],
      );

  Widget _mobileLayout(List<ReviewModel> reviews) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reviewList(reviews),
        ],
      );

  Widget _reviewList(List<ReviewModel> reviews) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.navyDeep,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Kata orang soal ${widget.wisata.name}',
                    style: AppText.heading(16, color: AppColors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_showForm)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
                    onPressed: () => setState(() => _showForm = true),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_showForm) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        hintText: 'Nama Anda',
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Rating: ', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 8),
                        ...List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => _rating = index + 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                color: AppColors.gold,
                                size: 24,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      style: const TextStyle(color: AppColors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pengalaman Anda...',
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showForm = false;
                                _nameController.clear();
                                _commentController.clear();
                                _rating = 5.0;
                              });
                            },
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                            ),
                            child: const Text('Kirim'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (reviews.isEmpty && !_showForm)
              const Text(
                'Belum ada ulasan. Jadilah yang pertama!',
                style: TextStyle(color: Colors.white60),
              )
            else
              ...reviews.map((r) => _ReviewTile(
                    review: r,
                    isUserReview: widget.userReviews.contains(r),
                    onDelete: () => widget.onDeleteReview(r.id),
                  )),
          ],
        ),
      );

  Widget _descCard(BuildContext ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.wisata.name,
            style: AppText.heading(18).copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.navyMid,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            widget.wisata.fullDesc,
            style: AppText.body(13).copyWith(height: 1.75),
            maxLines: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
}

// ─── Review Tile ──────────────────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final bool isUserReview;
  final VoidCallback onDelete;

  const _ReviewTile({
    required this.review,
    required this.isUserReview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(review.avatarInitial),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.comment,
                    style: AppText.body(13, color: AppColors.white.withValues(alpha: 0.9)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(review.rating, size: 12),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          review.userName,
                          style: AppText.body(11, color: AppColors.white.withValues(alpha: 0.6)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(review.date),
                        style: AppText.body(10, color: AppColors.white.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isUserReview)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Hapus Review'),
                      content: const Text('Apakah Anda yakin ingin menghapus review ini?'),
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
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months bulan lalu';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lalu';
    }
    return 'baru saja';
  }
}

// ─── Back Button ───────────────────────────────────────────────────────────────
class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_rounded, size: 13, color: AppColors.navyDeep),
              SizedBox(width: 4),
            ],
          ),
        ),
      );
}