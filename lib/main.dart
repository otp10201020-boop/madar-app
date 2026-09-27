import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = "https://your-domain.com/api.php";

void main() {
  runApp(const MadarSystemApp());
}

class MadarSystemApp extends StatefulWidget {
  const MadarSystemApp({super.key});

  @override
  State<MadarSystemApp> createState() => _MadarSystemAppState();
}

class _MadarSystemAppState extends State<MadarSystemApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منظومة المدار',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF06B6D4),
        cardColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF06B6D4),
          secondary: Color(0xFF10B981),
          surface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF10B981),
        cardColor: const Color(0xFF161B22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF161B22),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: AppSelectionScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class AppSelectionScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const AppSelectionScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('منظومة المدار'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  border: Border.all(
                    color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.security_rounded,
                  size: 64,
                  color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserAppScreen(onToggleTheme: onToggleTheme),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text('تطبيق مدار (المستخدم)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminAppScreen(onToggleTheme: onToggleTheme),
                      ),
                    );
                  },
                  icon: Icon(Icons.admin_panel_settings, color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4)),
                  label: Text(
                    'المدار الرئيسي (الإدارة العليا)',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      generatedBrowserLink = "https://your-domain.com/view.php?id=${DateTime.now().millisecondsSinceEpoch}";
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

class AdminAppScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminAppScreen({super.key, required this.onToggleTheme});

  @override
  State<AdminAppScreen> createState() => _AdminAppScreenState();
}

class _AdminAppScreenState extends State<AdminAppScreen> {
  List pendingRequests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=get_pending_requests'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(() => pendingRequests = data['requests']);
        }
      }
    } catch (_) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المدار الرئيسي - الإدارة'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRequests),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طلبات التفعيل المعلقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: pendingRequests.isEmpty
                        ? const Center(child: Text('لا توجد طلبات تفعيل معلقة'))
                        : ListView.builder(
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              final req = pendingRequests[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(req['name'] ?? ''),
                                  subtitle: Text('@${req['username']}'),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                    onPressed: () {},
                                    child: const Text('موافقة + كود', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
