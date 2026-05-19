import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ─── MODELS ───────────────────────────────────────────────────────────────────

class ReviewModel {
  final String id, userName, avatarInitial, comment;
  final double rating;
  final DateTime date;
  const ReviewModel({
    required this.id, required this.userName, required this.avatarInitial,
    required this.comment, required this.rating, required this.date,
  });
}

class WisataModel {
  final String id, name, shortDesc, fullDesc, imageUrl, category, location, mapsUrl;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final List<ReviewModel> reviews;
  final String jamBuka;
  final String hargaTiket;
  const WisataModel({
    required this.id, required this.name, required this.shortDesc,
    required this.fullDesc, required this.imageUrl, required this.category,
    required this.location, required this.mapsUrl,
    required this.rating, required this.reviewCount,
    this.tags = const [], this.reviews = const [],
    this.jamBuka = '-',
    this.hargaTiket = '-',
  });
}

class KulinerModel {
  final String id, name, shortDesc, fullDesc, imageUrl, priceRange, origin, mapsUrl;
  final double rating;
  final int reviewCount;
  final List<String> whereToFind;
  const KulinerModel({
    required this.id, required this.name, required this.shortDesc,
    required this.fullDesc, required this.imageUrl,
    required this.priceRange, required this.origin,
    required this.mapsUrl,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.whereToFind = const [],
  });
}

class BudayaModel {
  final String id, name, shortDesc, fullDesc, imageUrl, type, period;
  const BudayaModel({
    required this.id, required this.name, required this.shortDesc,
    required this.fullDesc, required this.imageUrl,
    required this.type, required this.period,
  });
}

class BeritaModel {
  final String id, title, summary, fullContent, imageUrl, category, author;
  final DateTime publishedAt;
  const BeritaModel({
    required this.id, required this.title, required this.summary,
    required this.fullContent, required this.imageUrl,
    required this.category, required this.author, required this.publishedAt,
  });
}

class KuisQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  const KuisQuestion({
    required this.question, required this.options,
    required this.correctIndex, required this.explanation,
  });
}

// ════════════════════════════════════════════════════════════════════════════════
// REVIEW STORAGE (untuk menyimpan review user di SharedPreferences)
// ════════════════════════════════════════════════════════════════════════════════
class ReviewStorage {
  static const String _key = 'user_reviews';
  
  static Future<void> addReview(String wisataId, ReviewModel review) async {
    final prefs = await SharedPreferences.getInstance();
    final allReviews = await getAllReviews();
    
    if (!allReviews.containsKey(wisataId)) {
      allReviews[wisataId] = [];
    }
    allReviews[wisataId]!.add(review);
    
    final jsonMap = <String, String>{};
    for (var entry in allReviews.entries) {
      jsonMap[entry.key] = jsonEncode(entry.value.map((r) => {
        'id': r.id,
        'userName': r.userName,
        'avatarInitial': r.avatarInitial,
        'comment': r.comment,
        'rating': r.rating,
        'date': r.date.toIso8601String(),
      }).toList());
    }
    await prefs.setString(_key, jsonEncode(jsonMap));
  }
  
  static Future<Map<String, List<ReviewModel>>> getAllReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return {};
    
    final Map<String, dynamic> jsonMap = jsonDecode(data);
    final result = <String, List<ReviewModel>>{};
    
    for (var entry in jsonMap.entries) {
      final List<dynamic> list = entry.value;
      result[entry.key] = list.map((item) => ReviewModel(
        id: item['id'],
        userName: item['userName'],
        avatarInitial: item['avatarInitial'],
        comment: item['comment'],
        rating: item['rating'],
        date: DateTime.parse(item['date']),
      )).toList();
    }
    return result;
  }
  
  static Future<void> deleteReview(String wisataId, String reviewId) async {
    final allReviews = await getAllReviews();
    if (allReviews.containsKey(wisataId)) {
      allReviews[wisataId]!.removeWhere((r) => r.id == reviewId);
      await _saveAllReviews(allReviews);
    }
  }
  
  static Future<void> _saveAllReviews(Map<String, List<ReviewModel>> allReviews) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = <String, String>{};
    for (var entry in allReviews.entries) {
      jsonMap[entry.key] = jsonEncode(entry.value.map((r) => {
        'id': r.id,
        'userName': r.userName,
        'avatarInitial': r.avatarInitial,
        'comment': r.comment,
        'rating': r.rating,
        'date': r.date.toIso8601String(),
      }).toList());
    }
    await prefs.setString(_key, jsonEncode(jsonMap));
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// DUMMY DATA
// ════════════════════════════════════════════════════════════════════════════════
class DummyData {

  // ── Reviews ────────────────────────────────────────────────────────────────
  static final _reviewsTaman = [
    ReviewModel(id:'r1', userName:'Dzakiyah Aulia', avatarInitial:'DZ',
      rating:5, comment:'Bagus tempatnya, harga murah. Lokasi terjangkau dan pemandangannya keren banget!',
      date: DateTime(2025,8,20)),
    ReviewModel(id:'r2', userName:'Andi Prasetyo', avatarInitial:'A',
      rating:4, comment:'Cocok buat santai bareng keluarga. Fasilitasnya lumayan lengkap.',
      date: DateTime(2025,7,15)),
    ReviewModel(id:'r3', userName:'Budi Santoso', avatarInitial:'B',
      rating:4, comment:'Pemandangan sawahnya bikin adem. Recommended!',
      date: DateTime(2025,6,30)),
  ];

  static final _reviewsSitu = [
    ReviewModel(id:'r4', userName:'Rina Marlina', avatarInitial:'RM',
      rating:5, comment:'Airnya jernih banget, suasana alamnya masih natural. Suka!',
      date: DateTime(2025,8,5)),
    ReviewModel(id:'r5', userName:'Hendra W', avatarInitial:'HW',
      rating:4, comment:'Bagus buat mancing, ikannya banyak. Akses jalan lumayan.',
      date: DateTime(2025,7,22)),
  ];

  // ── Wisata ─────────────────────────────────────────────────────────────────
  static final wisata = [
    WisataModel(
      id:'w1', name:'Taman Wisata Rido Galih', category:'Alam',
      location:'Desa Ridho Galih, Cibarusah',
      mapsUrl:'https://maps.google.com/?q=Taman+Wisata+Ridogalih+Asri+Cibarusah',
      rating: 4.6, reviewCount: 128,
      tags:['Alam','Keluarga','Foto'],
      jamBuka: '07.00 – 17.00',
      hargaTiket: 'Rp 10.000',
      imageUrl:'assets/images/imagewisata1.png',
      shortDesc:'Taman alam dengan pemandangan sawah dan pegunungan yang menenangkan.',
      fullDesc:
        'Taman Wisata Ridho Galih merupakan destinasi wisata alam yang terletak di kawasan Cibarusah. '
        'Dikelilingi hamparan sawah hijau dan bukit-bukit kecil yang asri, taman ini menawarkan '
        'ketenangan di tengah alam pedesaan Jawa Barat.\n\n'
        'Pengunjung dapat menikmati berbagai fasilitas seperti area piknik, kolam ikan, dan '
        'jalur trekking ringan yang cocok untuk semua usia. Saat matahari terbenam, panorama '
        'langit jingga yang memantul di permukaan kolam menjadi daya tarik tersendiri.\n\n'
        'Tempat ini juga sering dijadikan lokasi foto prewedding dan gathering komunitas karena '
        'suasananya yang asri dan harga tiket yang sangat terjangkau.',
      reviews: _reviewsTaman,
    ),
    WisataModel(
      id:'w2', name:'Taman Buaya Indonesia Jaya', category:'Alam',
      location:'Serang, Cibarusah',
      mapsUrl:'https://maps.google.com/?q=Taman+Buaya+Indonesia+Jaya+Cibarusah',
      rating: 4.3, reviewCount: 87,
      tags:['Edukasi','Satwa','Wisata Keluarga'],
      jamBuka: '08.00 – 16.00',
      hargaTiket: 'Rp 25.000',
      imageUrl:'assets/images/imagewisata2.png',
      shortDesc:'Tempat penangkaran buaya sekaligus wisata edukasi di Cibarusah.',
      fullDesc:
        'Taman Buaya Indonesia Jaya merupakan wisata edukasi yang menampilkan '
        'berbagai jenis buaya dalam area penangkaran yang aman untuk dikunjungi.\n\n'
        'Selain melihat langsung habitat buaya, pengunjung juga dapat menikmati '
        'suasana wisata keluarga dengan area santai dan spot foto menarik.\n\n'
        'Tempat ini cocok dikunjungi saat pagi atau sore hari agar suasana terasa '
        'lebih nyaman dan tidak terlalu panas.',
      reviews: _reviewsSitu,
    ),
    WisataModel(
      id:'w3', name:'Taman Lio Baheula', category:'Alam',
      location:'Cibarusah Kota',
      mapsUrl:'https://maps.google.com/?q=Taman+Lio+Baheula+Cibarusah',
      rating: 4.5, reviewCount: 62,
      tags:['Sawah','Edukasi','Foto'],
      jamBuka: '08.00 – 17.00',
      hargaTiket: 'Rp 5.000',
      imageUrl:'assets/images/imagewisata3.png',
      shortDesc:'Taman bernuansa tradisional dengan suasana asri dan nyaman.',
      fullDesc:
        'Taman Lio Baheula merupakan ruang wisata bernuansa tradisional yang '
        'mengangkat unsur budaya dan sejarah lokal Cibarusah.\n\n'
        'Pengunjung dapat menikmati suasana taman yang asri, area bersantai, '
        'serta berbagai spot foto dengan sentuhan desain khas tempo dulu.\n\n'
        'Tempat ini cocok untuk rekreasi keluarga maupun sekadar melepas penat '
        'di lingkungan yang tenang dan nyaman.',
      reviews: [],
    ),
  ];

  // ── Kuliner ────────────────────────────────────────────────────────────────
  static const kuliner = [
    KulinerModel(
      id:'k1', name:'Nasi Uduk Teh Yeti', origin:'Tradisi Betawi-Sunda',
      priceRange:'Rp 10.000 – 25.000',
      rating: 4.5, reviewCount: 94,
      whereToFind:['Warung Teh Yeti, Jl. Raya Cibarusah','Pasar Cibarusah'],
      imageUrl:'assets/images/imagekuliner1.webp',
      shortDesc:'Nasi uduk legendaris dengan lauk lengkap dan cita rasa khas.',
      fullDesc:
        'Nasi Uduk Teh Yeti dikenal sebagai salah satu kuliner favorit di Cibarusah '
        'dengan rasa gurih khas dan pilihan lauk yang beragam.\n\n'
        'Menu andalannya seperti semur jengkol, paru, daging sapi, hingga aneka '
        'gorengan selalu ramai diburu pengunjung sejak pagi hari.\n\n'
        'Dengan harga yang terjangkau dan cita rasa yang konsisten, tempat ini '
        'menjadi hidden gem sarapan favorit masyarakat sekitar.',
      mapsUrl: 'https://maps.app.goo.gl/917tMmDqWcLdj2Gj8',
    ),
    KulinerModel(
      id:'k2', name:'Pecak Sehati', origin:'Tradisi Betawi',
      priceRange:'Rp 25.000 – 60.000',
      rating: 4.7, reviewCount: 156,
      whereToFind:['Rumah Makan Betawi Asli, Cibarusah','Event kuliner tahunan'],
      imageUrl:'assets/images/imagekuliner2.jpg',
      shortDesc:'Ikan mas dengan sambal pecak pedas segar khas Betawi.',
      fullDesc:
        'Pecak Sehati adalah hidangan kebanggaan masyarakat Betawi yang masih lestari di Cibarusah. '
        'Ikan mas segar dimasak dengan sambal pecak pedas, menciptakan cita rasa yang sangat menggugah selera.\n\n'
        'Proses memasaknya cukup kompleks dan memerlukan keahlian khusus sambal pecak harus direndam '
        'terlebih dahulu untuk mengeluarkan rasa terbaiknya, kemudian dikombinasikan dengan '
        'rempah-rempah pilihan.\n\n'
        'Hidangan ini biasanya disajikan saat acara adat, pernikahan, dan perayaan keluarga '
        'sebagai simbol kekayaan kuliner Betawi-Bekasi.',
      mapsUrl: 'https://maps.app.goo.gl/7hTzrAbEyaWbJvQz9',
    ),
    KulinerModel(
      id:'k3', name:'Sop Iga', origin:'Kuliner Nusantara',
      priceRange:'Rp 40.000',
      rating: 4.4, reviewCount: 73,
      whereToFind:['Warung makan Cibarusah','Rumah makan keluarga'],
      imageUrl:'assets/images/imagekuliner3.webp',
      shortDesc:'Sop iga hangat dengan kuah gurih dan daging empuk.',
      fullDesc:
        'Sop Iga adalah hidangan khas Nusantara yang populer di Cibarusah. '
        'Daging iga sapi yang empuk dimasak dalam kuah gurih yang kaya rempah, '
        'menciptakan cita rasa yang lezat dan mengenyangkan.\n\n'
        'Hidangan ini biasanya disajikan sebagai menu utama dalam berbagai acara keluarga '
        'dan perayaan, menjadi pilihan favorit karena rasa yang konsisten dan kualitas bahan '
        'yang terbaik.'
        'oleh semua kalangan, dari anak-anak hingga orang tua.\n\n'
        'Asinan Bekasi dapat dengan mudah ditemukan di pedagang keliling dan pasar tradisional '
        'Cibarusah, terutama pada pagi dan siang hari.',
      mapsUrl: 'https://maps.app.goo.gl/vQHqLbhCHiKgS7WS7',
    ),
  ];

  // ── Budaya ─────────────────────────────────────────────────────────────────
  static const budaya = [
    BudayaModel(
      id: 'b1',
      name: 'Sejarah Cibarusah',
      type: 'sejarah',
      period: 'Abad ke-17 – sekarang',
      imageUrl: 'assets/images/imagesejarah2.png',
      shortDesc: 'Cibarusah menyimpan jejak sejarah panjang sejak era kolonial Belanda.',
      fullDesc:
        'Cibarusah merupakan salah satu kecamatan tertua di Kabupaten Bekasi yang memiliki '
        'rekam jejak sejarah panjang sejak abad ke-17.\n\n'
        'Pada masa penjajahan Belanda, kawasan ini menjadi daerah agraris penting yang memasok '
        'bahan pangan ke Batavia (kini Jakarta). Sistem tanam paksa (cultuurstelsel) yang '
        'diterapkan Belanda sangat mempengaruhi kehidupan masyarakat Cibarusah pada masa itu.\n\n'
        'Nama "Cibarusah" sendiri berasal dari bahasa Sunda kuno yang bermakna "sungai yang '
        'penuh barokah".',
    ),
    BudayaModel(
      id: 'b2',
      name: 'Batik Cibarusah',
      type: 'batik',
      period: 'Tradisi turun-temurun',
      imageUrl: 'assets/images/imagebatik2.png',
      shortDesc: 'Motif batik khas dengan corak flora dan fauna lokal Bekasi.',
      fullDesc:
        'Batik Cibarusah merupakan warisan budaya tekstil yang terus dijaga oleh para pengrajin lokal. '
        'Motif-motifnya terinspirasi dari kekayaan alam setempat: padi, ikan gabus, tanaman air, '
        'dan aliran sungai yang menjadi sumber kehidupan masyarakat.\n\n'
        'Proses pembuatannya masih menggunakan teknik batik tulis tradisional dengan malam '
        '(lilin batik) yang diaplikasikan menggunakan canting secara manual.\n\n'
        'Batik Cibarusah kini mulai dikenal secara nasional berkat program pelestarian '
        'yang didukung pemerintah daerah dan komunitas pengrajin lokal.',
    ),
  ];

  // ── Berita ─────────────────────────────────────────────────────────────────
  static final berita = [
    BeritaModel(
      id:'n1', category:'Tradisi', author:'Redaksi Cibarusah',
      publishedAt: DateTime(2025,10,12),
      imageUrl:'assets/images/imageberita1.jpeg',
      title:'Menjaga Bara Terakhir Lio Cibarusah',
      summary:'Kisah pelestarian lio tradisional yang menjadi bagian sejarah dan identitas budaya Cibarusah.',
      fullContent:
        'Lio atau tempat pembakaran bata tradisional pernah menjadi bagian penting dalam kehidupan '
        'masyarakat Cibarusah. Aktivitas ini tidak hanya menjadi sumber mata pencaharian, tetapi juga '
        'warisan budaya yang diwariskan secara turun-temurun.\n\n'
        'Seiring perkembangan zaman, jumlah lio tradisional mulai berkurang akibat modernisasi '
        'dan perubahan lingkungan. Meski begitu, beberapa warga masih mempertahankan keberadaannya '
        'sebagai simbol sejarah dan identitas lokal.\n\n'
        '"Menjaga lio berarti menjaga cerita dan perjuangan masyarakat tempo dulu," ujar salah satu '
        'tokoh warga yang masih melestarikan tradisi tersebut.',
    ),
    BeritaModel(
      id:'n2', category:'Budaya', author:'Redaksi Cibarusah',
      publishedAt: DateTime(2026,4,28),
      imageUrl:'assets/images/imageberita2.jpeg',
      title:'Menghidupkan Kembali Koridor Pejuang',
      summary:'Upaya menjadikan Cibarusah sebagai kawasan cagar budaya untuk menjaga sejarah perjuangan dan identitas lokal.',
      fullContent:
        'Cibarusah memiliki jejak sejarah panjang yang berkaitan dengan perjuangan masyarakat '
        'melawan penjajahan serta perkembangan budaya lokal di Kabupaten Bekasi.\n\n'
        'Melalui wacana pembentukan kawasan cagar budaya, berbagai situs bersejarah dan jalur '
        'perjuangan diharapkan dapat dilestarikan agar tetap dikenal oleh generasi muda.\n\n'
        'Langkah ini juga dinilai mampu menghidupkan kembali identitas Cibarusah sebagai '
        '“Koridor Pejuang” sekaligus membuka potensi wisata sejarah dan edukasi budaya.',
    ),
  ];

// ── Kuis ───────────────────────────────────────────────────────────────────
static const kuis = [
  // ==================== LEVEL 1: PEMULA (5 soal) ====================
  KuisQuestion(
    question: 'Kecamatan Cibarusah terletak di kabupaten mana?',
    options: ['Kabupaten Bogor', 'Kabupaten Bekasi', 'Kabupaten Karawang', 'Kabupaten Depok'],
    correctIndex: 1,
    explanation: 'Cibarusah adalah kecamatan yang berada di wilayah Kabupaten Bekasi, Provinsi Jawa Barat.',
  ),
  KuisQuestion(
    question: 'Apa arti nama "Cibarusah" dalam bahasa Sunda kuno?',
    options: ['Tanah yang subur', 'Hutan yang rimbun', 'Sungai yang penuh barokah', 'Gunung yang tinggi'],
    correctIndex: 2,
    explanation: '"Ci" berarti air/sungai dan "barusah" bermakna berkah dalam bahasa Sunda kuno.',
  ),
  KuisQuestion(
    question: 'Apa sambutan khas dalam bahasa Sunda yang digunakan di Cibarusah?',
    options: ['Wilujeung Sumping', 'Assalamualaikum', 'Selamat Pagi', 'Halo'],
    correctIndex: 0,
    explanation: '"Wilujeung Sumping" adalah salam khas Sunda yang berarti "Selamat Datang" dan sering digunakan di Cibarusah.',
  ),
  KuisQuestion(
    question: 'Apa karakteristik geografis utama Cibarusah?',
    options: ['Pantai dan lautan', 'Gurun dan padang pasir', 'Perbukitan, sawah, dan aliran sungai', 'Hutan tropis lebat'],
    correctIndex: 2,
    explanation: 'Cibarusah didominasi perbukitan, area persawahan, dan aliran sungai yang subur.',
  ),
  KuisQuestion(
    question: 'Sebutan "Tjibarusa" merupakan ejaan kuno dari nama Cibarusah pada masa?',
    options: ['Kerajaan Sunda', 'Penjajahan Belanda', 'Kemerdekaan', 'Orde Baru'],
    correctIndex: 1,
    explanation: 'Ejaan "Tjibarusa" digunakan pada masa kolonial Belanda dan masih tercatat dalam dokumen-dokumen sejarah.',
  ),

  // ==================== LEVEL 2: PENJELAJAH (5 soal) ====================
  KuisQuestion(
    question: 'Wisata alam apa yang terkenal di Cibarusah dengan pemandangan sawah dan perbukitan?',
    options: ['Taman Buaya Indonesia Jaya', 'Taman Wisata Rido Galih', 'Taman Lio Baheula', 'Situ Cileungsi'],
    correctIndex: 1,
    explanation: 'Taman Wisata Rido Galih adalah destinasi wisata alam di Cibarusah yang menawarkan pemandangan sawah hijau dan perbukitan.',
  ),
  KuisQuestion(
    question: 'Hewan apa yang menjadi daya tarik utama di Taman Buaya Indonesia Jaya?',
    options: ['Harimau', 'Buaya', 'Komodo', 'Ular Piton'],
    correctIndex: 1,
    explanation: 'Taman Buaya Indonesia Jaya adalah penangkaran buaya yang menjadi destinasi wisata edukasi di Cibarusah.',
  ),
  KuisQuestion(
    question: 'Kuliner khas Betawi berbahan ikan gabus dengan kuah hitam dari kluwek disebut?',
    options: ['Rendang Gabus', 'Gabus Pucung', 'Gabus Bakar', 'Gulai Gabus'],
    correctIndex: 1,
    explanation: 'Gabus Pucung adalah masakan Betawi berbahan ikan gabus dengan kuah hitam dari kluwek (pucung).',
  ),
  KuisQuestion(
    question: 'Nasi uduk legendaris di Cibarusah yang terkenal dengan lauk lengkapnya bernama?',
    options: ['Nasi Uduk Bu Tati', 'Nasi Uduk Teh Yeti', 'Nasi Uduk Mang Ujang', 'Nasi Uduk Pak Ade'],
    correctIndex: 1,
    explanation: 'Nasi Uduk Teh Yeti dikenal sebagai kuliner favorit di Cibarusah dengan lauk lengkap dan cita rasa khas.',
  ),
  KuisQuestion(
    question: 'Seni bela diri tradisional yang masih aktif dilestarikan di Cibarusah adalah?',
    options: ['Karate', 'Taekwondo', 'Pencak Silat', 'Judo'],
    correctIndex: 2,
    explanation: 'Pencak Silat adalah seni bela diri tradisional Betawi-Sunda yang masih lestari di Cibarusah.',
  ),

  // ==================== LEVEL 3: PENJAGA SEJARAH (5 soal) ====================
  KuisQuestion(
    question: 'Apa yang dimaksud dengan "Lio" di Cibarusah?',
    options: ['Tempat ibadah', 'Tempat pembakaran bata tradisional', 'Alat musik tradisional', 'Upacara adat'],
    correctIndex: 1,
    explanation: 'Lio adalah tempat pembakaran bata tradisional yang menjadi warisan budaya dan identitas sejarah Cibarusah.',
  ),
  KuisQuestion(
    question: 'Motif batik khas Cibarusah banyak terinspirasi dari simbol?',
    options: ['Naga dan Garuda', 'Padi, ikan gabus, dan aliran sungai', 'Gunung dan lautan', 'Bunga dan kupu-kupu'],
    correctIndex: 1,
    explanation: 'Motif batik Cibarusah terinspirasi dari kekayaan alam lokal seperti padi, ikan gabus, dan aliran sungai.',
  ),
  KuisQuestion(
    question: 'Apa tema utama dalam upaya pelestarian kawasan cagar budaya Cibarusah?',
    options: ['Koridor Pejuang', 'Kampung Batik', 'Desa Wisata', 'Lumbung Pangan'],
    correctIndex: 0,
    explanation: 'Cibarusah dijuluki sebagai "Koridor Pejuang" karena memiliki jejak sejarah perjuangan melawan penjajahan.',
  ),
  KuisQuestion(
    question: 'Sistem tanam paksa yang diterapkan Belanda di Cibarusah disebut?',
    options: ['Cultuurstelsel', 'Politik Etis', 'Tanam Paksa', 'Rodi'],
    correctIndex: 0,
    explanation: 'Cultuurstelsel adalah sistem tanam paksa yang diterapkan Belanda di Cibarusah pada abad ke-19.',
  ),
  KuisQuestion(
    question: 'Apa tujuan pembentukan kawasan cagar budaya di Cibarusah?',
    options: [
      'Membangun mal modern',
      'Melestarikan situs sejarah dan identitas lokal',
      'Membuka pabrik baru',
      'Menggusur pemukiman warga'
    ],
    correctIndex: 1,
    explanation: 'Kawasan cagar budaya bertujuan melestarikan situs bersejarah, jalur perjuangan, dan identitas lokal Cibarusah.',
  ),
];
}