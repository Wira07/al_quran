import 'package:flutter/material.dart';
import '../model/surah_model.dart';
import '../services/api_service.dart';
import 'detail_surah_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Surah>> futureSurah;

  @override
  void initState() {
    super.initState();
    futureSurah = ApiService().getSurah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Al-Qur\'an App'),
      ),
      body: FutureBuilder<List<Surah>>(
        future: futureSurah,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No Data'));
          }

          final surahList = snapshot.data!;

          return ListView.builder(
            itemCount: surahList.length,
            itemBuilder: (context, index) {
              final surah = surahList[index];

              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailSurahScreen(nomor: surah.nomor, namaSurah: surah.namaLatin),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    child: Text('${surah.nomor}'),
                  ),
                  title: Text(surah.namaLatin),
                  subtitle: Text('${surah.arti} • ${surah.jumlahAyat} ayat'),
                  trailing: Text(surah.nama),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
