import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/themes/app_theme.dart';

enum ShareMode { morning, night, challenge }

@RoutePage()
class CreateShareCardPage extends StatefulWidget {
  const CreateShareCardPage({super.key});

  @override
  State<CreateShareCardPage> createState() => _CreateShareCardPageState();
}

class _CreateShareCardPageState extends State<CreateShareCardPage> {
  final GlobalKey _globalKey = GlobalKey();
  static const MethodChannel _platform = MethodChannel('com.example.metabolicapp/share');
  bool _isSharing = false;
  
  // State for Modes
  ShareMode _selectedMode = ShareMode.morning;
  final TextEditingController _reflectionController = TextEditingController();
  String _reflectionText = "";

  // Privacy Settings
  bool _shareGlucose = true;
  bool _shareKetones = true;
  bool _shareWeight = false;
  bool _shareMacros = true;
  bool _shareNotes = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
    // _reflectionController.text = _reflectionText; // Start empty to show defaults
    _reflectionController.addListener(() {
      setState(() {
        _reflectionText = _reflectionController.text;
      });
    });
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareGlucose = prefs.getBool('privacy_share_glucose') ?? true;
      _shareKetones = prefs.getBool('privacy_share_ketones') ?? true;
      _shareWeight = prefs.getBool('privacy_share_weight') ?? false;
      _shareMacros = prefs.getBool('privacy_share_macros') ?? true;
      _shareNotes = prefs.getBool('privacy_share_notes') ?? false;
    });
  }

  Future<void> _saveToHistory(String type, String platform) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('sharing_history') ?? [];
    
    final newItem = {
      'date': DateTime.now().toIso8601String(),
      'type': type,
      'platform': platform,
      'icon': 0xe6e0, // Icons.wb_sunny code point (approx)
      'color': 0xFFFF9800, // Colors.orange value
    };
    
    history.insert(0, jsonEncode(newItem));
    await prefs.setStringList('sharing_history', history);
  }

  Future<void> _shareCard({bool simulateInstagram = false}) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final imagePath = await _captureCardImage();
      if (imagePath == null) {
        throw Exception('Failed to capture image');
      }

      if (simulateInstagram && Platform.isMacOS) {
        await Process.run('open', [imagePath]);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opened image preview')),
          );
        }
      } else {
        await Share.shareXFiles(
          [XFile(imagePath)], 
          text: simulateInstagram ? '#KetoPilot #MorningFocus' : 'Check out my KetoPilot progress!',
        );
      }
      await _saveToHistory(_getModeTitle(), simulateInstagram ? 'Preview' : 'System Share');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing card: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareDirectToApp({required String methodName, required String platformLabel}) async {
    if (!Platform.isAndroid) {
      await _shareCard(simulateInstagram: false);
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final imagePath = await _captureCardImage();
      if (imagePath == null) {
        throw Exception('Failed to capture image');
      }

      await _platform.invokeMethod(methodName, {
        'imagePath': imagePath,
        'text': 'Check out my KetoPilot progress!',
      });

      await _saveToHistory(_getModeTitle(), platformLabel);
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Share failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing card: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<String?> _captureCardImage() async {
    final renderObject = _globalKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    final ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final file = await File('${directory.path}/share_card.png').create();
    await file.writeAsBytes(pngBytes);
    return file.path;
  }

  String _getModeTitle() {
    switch (_selectedMode) {
      case ShareMode.morning: return 'Morning Focus';
      case ShareMode.night: return 'Night Reflection';
      case ShareMode.challenge: return 'Challenge Card';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Share Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Selector
            SegmentedButton<ShareMode>(
              segments: const [
                ButtonSegment(
                  value: ShareMode.morning,
                  label: Text('Morning'),
                  icon: Icon(Icons.wb_sunny),
                ),
                ButtonSegment(
                  value: ShareMode.night,
                  label: Text('Night'),
                  icon: Icon(Icons.nightlight_round),
                ),
                ButtonSegment(
                  value: ShareMode.challenge,
                  label: Text('Challenge'),
                  icon: Icon(Icons.emoji_events),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (Set<ShareMode> newSelection) {
                setState(() {
                  _selectedMode = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // The Card to be shared
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                // Removed fixed height to allow content to determine size
                constraints: const BoxConstraints(minHeight: 400),
                decoration: BoxDecoration(
                  gradient: _getGradient(),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: _buildCardContent(),
              ),
            ),
            
            // Reflection Input (Visible if Notes are enabled)
            if (_shareNotes) ...[
              const SizedBox(height: 24),
              TextField(
                controller: _reflectionController,
                decoration: const InputDecoration(
                  labelText: 'Add your reflection',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 2,
              ),
            ],

            const SizedBox(height: 32),
            if (Platform.isAndroid) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSharing ? null : () => _shareDirectToApp(methodName: 'shareToInstagram', platformLabel: 'Instagram'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Instagram'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSharing ? null : () => _shareDirectToApp(methodName: 'shareToFacebook', platformLabel: 'Facebook'),
                      icon: const Icon(Icons.facebook),
                      label: const Text('Facebook'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : () => _shareCard(simulateInstagram: false),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : () => _shareCard(simulateInstagram: false),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : () => _shareCard(simulateInstagram: true),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Preview'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey, // Neutral color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (_selectedMode) {
      case ShareMode.morning:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9966), Color(0xFFFF5E62)], // Sunrise
        );
      case ShareMode.night:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141E30), Color(0xFF243B55)], // Dark/Calm
        );
      case ShareMode.challenge:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDA22FF), Color(0xFF9733EE)], // Neon/Active
        );
    }
  }

  Widget _buildCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _selectedMode == ShareMode.challenge ? Icons.fitness_center : Icons.rocket_launch,
          size: 64,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        Text(
          _getModeTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Dynamic Content based on Mode
        // TODO: Connect to real data providers (Glucose, Ketones, Macros)
        if (_selectedMode == ShareMode.morning) _buildMorningContent(),
        if (_selectedMode == ShareMode.night) _buildNightContent(),
        if (_selectedMode == ShareMode.challenge) _buildChallengeContent(),
      ],
    );
  }

  Widget _buildMorningContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'Start Strong',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_shareGlucose) const _StatItem(label: 'Wake Glucose', value: '85', unit: 'mg/dL'),
            if (_shareKetones) const _StatItem(label: 'Ketones', value: '1.2', unit: 'mmol/L'),
            if (_shareWeight) const _StatItem(label: 'Weight', value: '165', unit: 'lbs'),
          ],
        ),
        if (_shareMacros) ...[
          const SizedBox(height: 24),
          const Text('Breakfast Fuel', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          _buildMacroRow(carbs: '5g', protein: '20g', fat: '30g'),
        ],
        if (_shareNotes) ...[
          const SizedBox(height: 24),
          _buildNoteCard(_reflectionText.isNotEmpty 
              ? '"$_reflectionText"' 
              : '"Rise and grind! Your ketones are fueling your brain today."'),
        ],
      ],
    );
  }

  Widget _buildNightContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_shareGlucose) const _StatItem(label: 'Avg Glucose', value: '92', unit: 'mg/dL'),
            const Column(
              children: [
                Icon(Icons.sentiment_very_satisfied, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text('Mood', style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ],
        ),
        if (_shareMacros) ...[
          const SizedBox(height: 24),
          const Text('Daily Intake', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          _buildMacroRow(carbs: '20g', protein: '110g', fat: '140g'),
        ],
        if (_shareNotes) ...[
          const SizedBox(height: 24),
          _buildNoteCard(_reflectionText.isNotEmpty 
              ? '"$_reflectionText"' 
              : '"What a day! Stayed in ketosis despite the stress."'),
        ],
      ],
    );
  }

  Widget _buildChallengeContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: 'Duration', value: '45', unit: 'min'),
            _StatItem(label: 'Burn', value: '350', unit: 'kcal'),
          ],
        ),
        if (_shareGlucose) ...[
          const SizedBox(height: 24),
          const _StatItem(label: 'Post-Workout Glucose', value: '90', unit: 'mg/dL'),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          children: [
            _buildBadge(Icons.local_fire_department, 'Keto Powered'),
            _buildBadge(Icons.timer, 'PR Smashed'),
          ],
        ),
        if (_shareNotes) ...[
          const SizedBox(height: 24),
          _buildNoteCard(_reflectionText.isNotEmpty 
              ? '"$_reflectionText"' 
              : '"Crushing goals one ketone at a time!"'),
        ],
        const SizedBox(height: 16),
        const Text(
          '#KetoAthlete #Gains #NoDaysOff',
          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildMacroRow({required String carbs, required String protein, required String fat}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroItem(label: 'Carbs', value: carbs, color: Colors.redAccent),
          _MacroItem(label: 'Protein', value: protein, color: Colors.blueAccent),
          _MacroItem(label: 'Fat', value: fat, color: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
      label: Text(label, style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(4),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
