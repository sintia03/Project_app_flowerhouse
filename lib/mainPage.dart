import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final url = Uri.parse('http://10.0.2.2/app_flowerhouse_api/catatan.php');

  late Future<List<dynamic>> _futureCatatan;

  @override
  void initState() {
    super.initState();
    _futureCatatan = getCatatanFlows();
  }

  void _refreshData() {
    setState(() {
      _futureCatatan = getCatatanFlows();
    });
  }

  // fungsi untuk ambil data catatan flows :
  Future<List<dynamic>> getCatatanFlows() async {
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

  // fungsi untuk post catatan flows :
  Future<void> postCatatanFlows(String nominal, String kategori) async {
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nominal": nominal, "kategori": kategori}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data Berhasil Ditambahkan'),
              backgroundColor: Color.fromARGB(255, 28, 254, 24),
            ),
          );
          _refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data Gagal Ditambahkan'),
              backgroundColor: Color.fromARGB(255, 254, 24, 24),
            ),
          );
        }
      } else {
        throw Exception('Gagal Menyimpan ke Server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi Kesalahan: $e'),
          backgroundColor: const Color.fromARGB(255, 254, 24, 24),
        ),
      );
    }
  }

  // fungsi untuk update catatan flows :
  Future<void> putCatatanFlows(
    String id,
    String nominal,
    String kategori,
  ) async {
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "nominal": nominal, "kategori": kategori}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data Berhasil Diubah'),
              backgroundColor: Color.fromARGB(255, 28, 254, 24),
            ),
          );
          _refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data Gagal Diubah'),
              backgroundColor: Color.fromARGB(255, 254, 24, 24),
            ),
          );
        }
      } else {
        throw Exception('Gagal Mengubah Data di Server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi Kesalahan: $e'),
          backgroundColor: const Color.fromARGB(255, 254, 24, 24),
        ),
      );
    }
  }

  // fungsi untuk hapus catatan flows :
  Future<void> deleteCatatanFlows(String id) async {
    try {
      final deleteUrl = Uri.parse(
        'http://10.0.2.2/app_flowerhouse_api/catatan.php?id=$id',
      );

      final response = await http.delete(deleteUrl);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data Berhasil Dihapus'),
              backgroundColor: Color.fromARGB(255, 28, 254, 24),
            ),
          );
          _refreshData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data Gagal Dihapus: ${responseData['message']}'),
              backgroundColor: Color.fromARGB(255, 254, 24, 24),
            ),
          );
        }
      } else {
        throw Exception('Gagal Menghapus Data, status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi Kesalahan: $e'),
          backgroundColor: const Color.fromARGB(255, 254, 24, 24),
        ),
      );
    }
  }

  // dialog konfirmasi sebelum hapus data
  void konfirmasiHapus(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: const Text('Apakah kamu yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteCatatanFlows(id);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // form tambah / edit catatan (mode ditentukan dari parameter catatanEdit)
  void tampilkanForm(
    BuildContext context, {
    Map<String, dynamic>? catatanEdit,
  }) {
    final bool isEdit = catatanEdit != null;

    final TextEditingController _nominal = TextEditingController(
      text: isEdit ? catatanEdit['nominal'].toString() : '',
    );
    final List<String> _listKategori = ['Pemasukan', 'Belanja'];

    String _kategoriDipilih = 'Pemasukan';
    if (isEdit) {
      String kategoriAsli = catatanEdit['kategori'].toString().toLowerCase();
      _kategoriDipilih = kategoriAsli == 'belanja' ? 'Belanja' : 'Pemasukan';
    }

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
                  Text(
                    isEdit
                        ? 'Edit Catatan Pemesanan'
                        : 'Tambah Catatan Pemesanan',
                  ),
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
                    onPressed: () async {
                      if (_nominal.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nominal Harus Diisi Oke'),
                            backgroundColor: const Color.fromARGB(
                              255,
                              252,
                              110,
                              67,
                            ),
                          ),
                        );
                        return;
                      }

                      if (isEdit) {
                        await putCatatanFlows(
                          catatanEdit['id'].toString(),
                          _nominal.text,
                          _kategoriDipilih,
                        );
                      } else {
                        await postCatatanFlows(_nominal.text, _kategoriDipilih);
                      }

                      _nominal.clear();
                      Navigator.pop(context);
                    },
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===== Bagian rekap =====
  Map<String, double> _hitungRekap(List<dynamic> listData) {
    double totalPemasukan = 0;
    double totalBelanja = 0;

    for (var catatan in listData) {
      double nominal = double.tryParse(catatan['nominal'].toString()) ?? 0;
      String kategori = catatan['kategori'].toString().toLowerCase();

      if (kategori == 'pemasukan') {
        totalPemasukan += nominal;
      } else if (kategori == 'belanja') {
        totalBelanja += nominal;
      }
    }

    return {
      'pemasukan': totalPemasukan,
      'belanja': totalBelanja,
      'saldo': totalPemasukan - totalBelanja,
    };
  }

  // format angka jadi 1.000.000 tanpa perlu package intl
  String _formatRupiah(double value) {
    String s = value.toInt().abs().toString();
    String hasil = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      hasil = s[i] + hasil;
      count++;
      if (count % 3 == 0 && i != 0) hasil = '.$hasil';
    }
    return (value < 0 ? '-Rp. ' : 'Rp. ') + hasil;
  }

  Widget _buildRekapCard(List<dynamic> listData) {
    final rekap = _hitungRekap(listData);

    return Container(
      margin: EdgeInsets.fromLTRB(15, 12, 15, 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Saat Ini',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            _formatRupiah(rekap['saldo']!),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rekapItem(
                icon: Icons.arrow_upward,
                label: 'Pemasukan',
                value: rekap['pemasukan']!,
                color: Colors.greenAccent.shade100,
              ),
              Container(width: 1, height: 36, color: Colors.white30),
              _rekapItem(
                icon: Icons.arrow_downward,
                label: 'Belanja',
                value: rekap['belanja']!,
                color: Colors.redAccent.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rekapItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        SizedBox(height: 4),
        Text(
          _formatRupiah(value),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  // ===== Akhir bagian rekap =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        elevation: 0,
        backgroundColor: Colors.pink.shade400,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "🌸 Flower House",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Pencatatan Pemesanan",
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.pink),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<List<dynamic>>(
          future: _futureCatatan,
          builder: (context, snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            // error
            if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(height: 100),
                  Center(child: Text('Terjadi Kesalahan : ${snapshot.error}')),
                ],
              );
            }
            // data kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: [
                  _buildRekapCard([]),
                  SizedBox(height: 100),
                  Center(child: Text('Data Belum Tersedia')),
                ],
              );
            }

            // data tersedia -> tampilkan rekap + list
            List<dynamic> listData = snapshot.data!;

            return Column(
              children: [
                _buildRekapCard(listData),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: listData.length,
                    itemBuilder: (context, index) {
                      var catatan = listData[index];

                      bool isPemasukan =
                          catatan['kategori'].toString().toLowerCase() ==
                          'pemasukan';

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPemasukan
                                ? const Color.fromARGB(255, 170, 227, 172)
                                : const Color.fromARGB(255, 239, 157, 151),
                            child: Icon(
                              isPemasukan
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isPemasukan ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            'Rp. ${catatan['nominal']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text('Keterangan: ${catatan['kategori']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  tampilkanForm(context, catatanEdit: catatan);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  konfirmasiHapus(
                                    context,
                                    catatan['id'].toString(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tampilkanForm(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
