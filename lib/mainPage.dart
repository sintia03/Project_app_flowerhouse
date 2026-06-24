import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  Future<List<dynamic>> getCatatanFlows() async {
    final url = Uri.parse('http://10.0.2.2/app_flowerhouse_api/catatan.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal Memuat Data');
      }
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  void tampilkanForm(BuildContext context) {
    //deklarasi controller dan variabel :
    final TextEditingController _nominal = TextEditingController();
    final List<String> _listKategori = ['Pemasukan', 'Belanja'];
    String _kategoriDipilih = 'Pemasukan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModelState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tambah Catatan Pemesanan'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nominal,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nominal (Rp)',
                      prefixText: 'Rp. ',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: _kategoriDipilih,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _listKategori.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModelState(() {
                        _kategoriDipilih = newValue!;
                      });
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      _nominal.clear();
                      setState(() {
                        _kategoriDipilih = 'Pemasukan';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Pemesanan Bunga'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getCatatanFlows(),
        builder: (context, snapshot) {
          //jika masi loading:
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          //jika terjadi error, misal server api nya mati.
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi Kesalahan : ${snapshot.error}'));
          }
          //jika data kososng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Data Belum Tersedia'));
          }
          //jika sukses, tampilkan data dalam bentuk listview
          List<dynamic> listData = snapshot.data!;
          return ListView.builder(
            itemCount: listData.length,
            itemBuilder: (context, index) {
              var catatan = listData[index];

              //agar warna dan icon kedua nya berbeda
              bool isPemasukan =
                  catatan['kategori'].toString().toLowerCase() == 'pemasukan';
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPemasukan
                        ? const Color.fromARGB(255, 170, 227, 172)
                        : const Color.fromARGB(255, 239, 157, 151),
                    child: Icon(
                      isPemasukan ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPemasukan ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    'Rp. ${catatan['nominal']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Keterangan: ${catatan['kategori']}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //ketika di tekan akan menampilkan sebuah form input catatan pemesanan bunga
          tampilkanForm(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
