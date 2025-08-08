import 'package:flutter/material.dart';
import 'package:native_log_plus/native_log.dart' as native_log;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _useQueue = false;
  List<String> _logHistory = [];

  @override
  void initState() {
    super.initState();
    _tagController.text = 'FlutterDemo';
    _messageController.text = 'Hello Native Log!';
  }

  void _logMessage(int level, String levelName) {
    final tag = _tagController.text;
    final message = _messageController.text;
    
    if (_useQueue) {
      native_log.customLogWithQueue(level, tag, message);
    } else {
      native_log.customLog(level, tag, message);
    }
    
    setState(() {
      _logHistory.insert(0, '[$levelName] $tag: $message');
      if (_logHistory.length > 20) {
        _logHistory.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Log Plus Plugin'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Use Queue:'),
                  Switch(
                    value: _useQueue,
                    onChanged: (value) {
                      setState(() {
                        _useQueue = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _logMessage(native_log.LogLevel.verbose, 'VERBOSE'),
                    child: const Text('VERBOSE'),
                  ),
                  ElevatedButton(
                    onPressed: () => _logMessage(native_log.LogLevel.debug, 'DEBUG'),
                    child: const Text('DEBUG'),
                  ),
                  ElevatedButton(
                    onPressed: () => _logMessage(native_log.LogLevel.info, 'INFO'),
                    child: const Text('INFO'),
                  ),
                  ElevatedButton(
                    onPressed: () => _logMessage(native_log.LogLevel.warn, 'WARN'),
                    child: const Text('WARN'),
                  ),
                  ElevatedButton(
                    onPressed: () => _logMessage(native_log.LogLevel.error, 'ERROR'),
                    child: const Text('ERROR'),
                  ),
                  ElevatedButton(
                    onPressed: () => _logMessage(native_log.LogLevel.fatal, 'FATAL'),
                    child: const Text('FATAL'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Log History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: _logHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_logHistory[index]),
                      );
                    },
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