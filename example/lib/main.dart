import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iris_sdk_flutter/iris_sdk_flutter.dart';

/// Minimal host app for `iris_sdk_flutter`.
///
/// It exists to prove the package builds, links against the vendor binaries
/// and round-trips over the method channel on both platforms — not to
/// demonstrate a real verification flow. Reading the SDK version already
/// exercises the whole chain: Dart → method channel → native plugin → the
/// bundled PassportReader framework/aar.
void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iris_sdk_flutter example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _verifier = IrisFaceVerifier();

  String _version = 'reading…';
  String? _outcome;
  Uint8List? _face;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _readVersion();
  }

  Future<void> _readVersion() async {
    final version = await _guard(() => _verifier.sdkVersion);
    if (mounted) setState(() => _version = version ?? 'unavailable');
  }

  Future<void> _verify() async {
    setState(() {
      _running = true;
      _outcome = null;
      _face = null;
    });

    final result = await _guard(() => _verifier.verify(_placeholderPortrait));

    if (!mounted) return;
    setState(() {
      _running = false;
      _outcome = result?.outcome.name ?? 'error';
      _face = result?.face;
    });
  }

  /// Runs [action], reporting a platform failure in a snackbar instead of
  /// crashing — on a simulator or a device without a camera, the SDK is
  /// expected to fail rather than succeed.
  Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('iris_sdk_flutter')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SDK version: $_version', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'Verification runs against a blank placeholder portrait, so it is '
                'expected to fail — the point is that the call reaches the native '
                'SDK and comes back.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _running ? null : _verify,
                child: Text(_running ? 'Verifying…' : 'Run face verification'),
              ),
              if (_outcome != null) ...[
                const SizedBox(height: 24),
                Text('Outcome: $_outcome', style: Theme.of(context).textTheme.titleMedium),
              ],
              if (_face != null) ...[const SizedBox(height: 16), Image.memory(_face!, height: 160)],
            ],
          ),
        ),
      ),
    );
  }
}

/// A 1x1 grey PNG standing in for the reference portrait that a real caller
/// would take from an identity document's NFC chip (DG2). Inlined rather than
/// bundled as an asset so the example carries no binaries of its own.
final Uint8List _placeholderPortrait = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR42mOYN28eAAO4AdvUX8G3AAAAAElFTkSuQmCC',
);
