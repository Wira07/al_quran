import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = MyApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Al-Quran Digital',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versi 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Settings section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'TAMPILAN',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Mode Gelap'),
              subtitle: Text(isDark ? 'Aktif' : 'Nonaktif'),
              value: isDark,
              activeColor: theme.colorScheme.primary,
              onChanged: (_) => appState?.toggleTheme(),
            ),
          ),

          const SizedBox(height: 20),

          // About section
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'TENTANG',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Dibuat oleh'),
                  subtitle: const Text(
                    'Wira Sukma Saputra',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Divider(height: 1, indent: 56, color: theme.dividerColor),
                ListTile(
                  leading: Icon(
                    Icons.code_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Framework'),
                  subtitle: const Text('Flutter'),
                ),
                Divider(height: 1, indent: 56, color: theme.dividerColor),
                ListTile(
                  leading: Icon(
                    Icons.api_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Sumber Data'),
                  subtitle: const Text('equran.id & aladhan.com'),
                ),
                Divider(height: 1, indent: 56, color: theme.dividerColor),
                ListTile(
                  leading: Icon(
                    Icons.calendar_today_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Tahun'),
                  subtitle: const Text('2026'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Credits footer
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dibuat dengan cinta untuk umat',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\u00a9 2026 Wira Sukma Saputra',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
