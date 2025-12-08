import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

@RoutePage()
class SharingHistoryPage extends StatefulWidget {
  const SharingHistoryPage({super.key});

  @override
  State<SharingHistoryPage> createState() => _SharingHistoryPageState();
}

class _SharingHistoryPageState extends State<SharingHistoryPage> {
  List<Map<String, dynamic>> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList('sharing_history') ?? [];
    
    setState(() {
      _historyItems = historyJson.map((item) {
        try {
          return jsonDecode(item) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{};
        }
      }).toList();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getIconForTitle(String title) {
    if (title.contains('Morning')) return Icons.wb_sunny;
    if (title.contains('Night')) return Icons.nightlight_round;
    if (title.contains('Challenge')) return Icons.emoji_events;
    return Icons.share;
  }

  Color _getColorForTitle(String title) {
    if (title.contains('Morning')) return Colors.orange;
    if (title.contains('Night')) return Colors.blueGrey;
    if (title.contains('Challenge')) return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (_historyItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sharing History')),
        body: const Center(
          child: Text('No sharing history yet.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sharing History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('sharing_history');
              setState(() {
                _historyItems = [];
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          final title = item['title'] ?? item['type'] ?? 'Share Card';
          final icon = _getIconForTitle(title);
          final color = _getColorForTitle(title);

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${_formatDate(item['date'])} • via ${item['platform']}'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // TODO: Show details of shared item
            },
          );
        },
      ),
    );
  }
}
