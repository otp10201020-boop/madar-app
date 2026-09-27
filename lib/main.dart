import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ضع رابط السيرفر/الاستضافة الخاص بك هنا
const String baseUrl = "https://your-domain.com/api.php";

void main() {
  runApp(const MadarUserApp());
}

class MadarUserApp extends StatefulWidget {
  const MadarUserApp({super.key});

  @override
  State<MadarUserApp> createState() => _MadarUserAppState();
}

class _MadarUserAppState extends State<MadarUserApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق مدار',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF06B6D4),
        cardColor: const Color(0xFFFFFFFF),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF10B981),
        cardColor: const Color(0xFF161B22),
      ),
      home: UserAppScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class UserAppScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const UserAppScreen({super.key, required this.onToggleTheme});

  @override
  State<UserAppScreen> createState() => _UserAppScreenState();
}

class _UserAppScreenState extends State<UserAppScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  String generatedBrowserLink = '';

  Future<void> _activateCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl?action=activate_code'),
        body: json.encode({'user_id': 1, 'code': code}),
      );
      final data = json.decode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? '')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر الاتصال بالسيرفر')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _generateShareLink() {
    setState(() {
      generatedBrowserLink = "$baseUrl/view.php?id=${DateTime.now().millisecondsSinceEpoch}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق مدار'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 60,
                      color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 12),
                    const Text('تفعيل اشتراك تطبيق مدار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'LOC-XXXX-XXXX-XXXX',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                        ),
                        onPressed: isLoading ? null : _activateCode,
                        child: const Text('تفعيل بالكود', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('إنشاء رابط للمتصفح الخارجية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                      ),
                      onPressed: _generateShareLink,
                      icon: const Icon(Icons.link, color: Colors.white),
                      label: const Text('توليد رابط للمتصفح', style: TextStyle(color: Colors.white)),
                    ),
                    if (generatedBrowserLink.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SelectableText(
                        generatedBrowserLink,
                        style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold),
                      ),
                    ]
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
