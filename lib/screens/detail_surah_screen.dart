import 'package:flutter/material.dart';
import '../model/ayat_model.dart';
import '../services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';

enum ViewMode { perAyat, bacaan, terjemahan }

class DetailSurahScreen extends StatefulWidget {
  final int nomor;
  final String namaSurah;

  const DetailSurahScreen({
    super.key,
    required this.nomor,
    required this.namaSurah,
  });

  @override
  State<DetailSurahScreen> createState() => _DetailSurahScreenState();
}

class _DetailSurahScreenState extends State<DetailSurahScreen> {
  late Future<List<Ayat>> _futureAyat;
  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;
  ViewMode _viewMode = ViewMode.perAyat;

  @override
  void initState() {
    super.initState();
    _futureAyat = ApiService().getDetailSurah(widget.nomor);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingIndex = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _playAudio(String url, int index) async {
    try {
      if (_playingIndex == index) {
        await _player.pause();
        setState(() => _playingIndex = null);
      } else {
        await _player.stop();
        await _player.play(UrlSource(url));
        setState(() => _playingIndex = index);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memutar audio: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaSurah),
        actions: [
          PopupMenuButton<ViewMode>(
            icon: const Icon(Icons.view_agenda_rounded),
            tooltip: 'Mode Tampilan',
            onSelected: (mode) => setState(() => _viewMode = mode),
            itemBuilder: (_) => [
              _buildMenuItem(
                theme,
                ViewMode.perAyat,
                Icons.view_list_rounded,
                'Per Ayat',
              ),
              _buildMenuItem(
                theme,
                ViewMode.bacaan,
                Icons.auto_stories_rounded,
                'Mushaf',
              ),
              _buildMenuItem(
                theme,
                ViewMode.terjemahan,
                Icons.translate_rounded,
                'Terjemahan',
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Ayat>>(
        future: _futureAyat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat data'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _futureAyat = ApiService().getDetailSurah(widget.nomor);
                    }),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final ayatList = snapshot.data!;
          switch (_viewMode) {
            case ViewMode.perAyat:
              return _buildPerAyatView(ayatList, theme);
            case ViewMode.bacaan:
              return _buildMushafView(ayatList, theme);
            case ViewMode.terjemahan:
              return _buildTerjemahanView(ayatList, theme);
          }
        },
      ),
    );
  }

  PopupMenuItem<ViewMode> _buildMenuItem(
    ThemeData theme,
    ViewMode mode,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(
            icon,
            color: _viewMode == mode ? theme.colorScheme.primary : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildPerAyatView(List<Ayat> ayatList, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: ayatList.length,
      itemBuilder: (context, index) {
        final ayat = ayatList[index];
        final isPlaying = _playingIndex == index;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${ayat.nomorAyat}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_rounded
                              : Icons.play_circle_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => _playAudio(ayat.audio, index),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Arabic text
                Text(
                  ayat.teksArab,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    height: 2.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                // Latin
                Text(
                  ayat.teksLatin,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Translation
                Text(
                  ayat.teksIndonesia,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMushafView(List<Ayat> ayatList, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2128) : const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Ornamental header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.namaSurah,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (widget.nomor != 9) ...[
                    const SizedBox(height: 8),
                    Text(
                      '\u{FDFD}',
                      style: TextStyle(
                        fontSize: 34,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Decorative line
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    theme.colorScheme.primary.withValues(alpha: 0.5),
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Continuous Arabic text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: RichText(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    height: 2.4,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                  children: ayatList.map((ayat) {
                    return TextSpan(
                      children: [
                        TextSpan(text: ayat.teksArab),
                        TextSpan(
                          text:
                              ' \u{FD3E}${_toArabicNumber(ayat.nomorAyat)}\u{FD3F} ',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            // Bottom ornament
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.04),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerjemahanView(List<Ayat> ayatList, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ayatList.length,
      separatorBuilder: (_, __) => Divider(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        height: 24,
      ),
      itemBuilder: (context, index) {
        final ayat = ayatList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${ayat.nomorAyat}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ayat.teksIndonesia,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _toArabicNumber(int number) {
    const arabicDigits = [
      '\u0660',
      '\u0661',
      '\u0662',
      '\u0663',
      '\u0664',
      '\u0665',
      '\u0666',
      '\u0667',
      '\u0668',
      '\u0669',
    ];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }
}
