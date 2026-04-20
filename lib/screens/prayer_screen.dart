import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/hijri_converter.dart';
import '../utils/city_data.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Map<String, String> _prayerTimes = {};
  bool _isLoading = true;
  String _selectedCity = 'Jakarta';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCity = prefs.getString('city') ?? 'Jakarta';
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final city = CityData.cities.firstWhere(
        (c) => c['name'] == _selectedCity,
        orElse: () => CityData.cities.first,
      );
      final now = DateTime.now();
      final dateStr =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final lat = city['lat'];
      final lon = city['lon'];
      final url =
          'https://api.aladhan.com/v1/timings/$dateStr?latitude=$lat&longitude=$lon&method=20';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;
        setState(() {
          _prayerTimes = {
            'Subuh': _cleanTime(timings['Fajr'] ?? '-'),
            'Syuruq': _cleanTime(timings['Sunrise'] ?? '-'),
            'Dzuhur': _cleanTime(timings['Dhuhr'] ?? '-'),
            'Ashar': _cleanTime(timings['Asr'] ?? '-'),
            'Maghrib': _cleanTime(timings['Maghrib'] ?? '-'),
            'Isya': _cleanTime(timings['Isha'] ?? '-'),
          };
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat jadwal salat';
      });
    }
  }

  String _cleanTime(String time) {
    return time.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
  }

  Future<void> _selectCity() async {
    final cities = CityData.cities.map((c) => c['name'] as String).toList();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Kota',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: cities.length,
                    itemBuilder: (_, i) {
                      final isSelected = cities[i] == _selectedCity;
                      return ListTile(
                        title: Text(cities[i]),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, cities[i]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != _selectedCity) {
      _selectedCity = result;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('city', _selectedCity);
      _fetchPrayerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hijri = HijriConverter.fromGregorian(now);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(
                          Icons.mosque_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hijri.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(now),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _selectCity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedCity,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Jadwal Salat'),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(_error!),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchPrayerTimes,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_buildPrayerCards(theme)),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPrayerCards(ThemeData theme) {
    final icons = {
      'Subuh': Icons.nights_stay_rounded,
      'Syuruq': Icons.wb_twilight_rounded,
      'Dzuhur': Icons.wb_sunny_rounded,
      'Ashar': Icons.sunny_snowing,
      'Maghrib': Icons.wb_twilight_rounded,
      'Isya': Icons.dark_mode_rounded,
    };

    final colors = {
      'Subuh': const Color(0xFF1A237E),
      'Syuruq': const Color(0xFFFF6F00),
      'Dzuhur': const Color(0xFFF9A825),
      'Ashar': const Color(0xFFEF6C00),
      'Maghrib': const Color(0xFFD84315),
      'Isya': const Color(0xFF283593),
    };

    return _prayerTimes.entries.map((entry) {
      final isNext = _isNextPrayer(entry.key);

      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isNext
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (colors[entry.key] ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icons[entry.key] ?? Icons.access_time,
                  color: colors[entry.key] ?? theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isNext)
                      Text(
                        'Waktu salat berikutnya',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                entry.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNext ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  bool _isNextPrayer(String name) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (final entry in _prayerTimes.entries) {
      if (entry.key == 'Syuruq') continue;
      final timeStr = entry.value.split(' ').first;
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final secs = int.tryParse(parts[1]) ?? 0;
        final totalMinutes = minutes * 60 + secs;
        if (totalMinutes > currentMinutes) {
          return entry.key == name;
        }
      }
    }
    return name == 'Subuh';
  }

  String _formatDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
