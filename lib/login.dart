import 'package:app_flowerhouse/db_helper.dart';
import 'package:app_flowerhouse/mainPage.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool islogin = true;
  //controller
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _konfirmasi_password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Image.asset('images/banner1.jpeg'),
            SizedBox(height: 70),
            TextField(
              controller: _username,
              decoration: InputDecoration(
                labelText: 'Username',
                icon: Icon(Icons.person),
              ),
            ),

            SizedBox(height: 25),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                icon: Icon(Icons.lock),
              ),
            ),
            if (islogin == false) ...[
              SizedBox(height: 25),
              TextField(
                controller: _konfirmasi_password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  icon: Icon(Icons.lock),
                ),
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(islogin ? 'Login' : 'Registrasi'),
              onPressed: () async {
                DbHelper _db = DbHelper();

                if (islogin) {
                  //logika untuk login:
                  bool loginSukses = await _db.chekLogin(
                    _username.text,
                    _password.text,
                  );

                  if (loginSukses) {
                    //masuk ke halaman utama
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Mainpage()),
                    );
                  } else {
                    //tampilkan pesan username atau password salah
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Username atau Password salah'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 7),
                      ),
                    );

                    //tampilkan pesan username atau password salah
                  }
                } else {
                  //logika untuk registrasi:
                  if (_password.text == _konfirmasi_password.text &&
                      _username.text.isNotEmpty) {
                    await _db.register(_username.text, _password.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registrasi Berhasil! Anda Sudah Bisa Login',
                        ),
                        backgroundColor: const Color.fromARGB(255, 27, 202, 59),
                        duration: Duration(seconds: 7),
                      ),
                    );

                    //kembali ke mode login lagi
                    setState(() {
                      islogin = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registrasi Gagal! Pastikan Nama dan Password Sudah Sesuai Ketentuan',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 7),
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 25),
            TextButton(
              onPressed: () {
                setState(() {
                  islogin = !islogin;
                });
              },
              child: Text(
                islogin
                    ? 'Belum Punya Akun? Daftar'
                    : 'Sudah Punya Akun? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
