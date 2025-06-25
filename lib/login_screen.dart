import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:root_checker_plus/root_checker_plus.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    checkRootOrJailbreak();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkRootOrJailbreak(); // Called when app resumes from background
    }
  }

  bool rootedCheck = false;
  bool jailbreak = false;
  String? token;
  final uuid = Uuid();
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  bool _isAuthenticating = false;

  checkRootOrJailbreak() {
    androidRootChecker();
    iosJailbreak();
    if (!rootedCheck || !jailbreak) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> androidRootChecker() async {
    try {
      rootedCheck = (await RootCheckerPlus.isRootChecker())!;
    } on PlatformException {
      rootedCheck = false;
    }
    if (!mounted) return;
    setState(() {
      rootedCheck = rootedCheck;
    });
  }

  Future<void> iosJailbreak() async {
    try {
      jailbreak = (await RootCheckerPlus.isJailbreak())!;
    } on PlatformException {
      jailbreak = false;
    }
    if (!mounted) return;
    setState(() {
      jailbreak = jailbreak;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    token = await secureStorage.read(key: 'token');
    log(token!);
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      try {
        setState(() => _isAuthenticating = true);
        bool canAuthenticate =
            await auth.canCheckBiometrics || await auth.isDeviceSupported();
        if (!canAuthenticate) {
          _showMessage("Biometric authentication is not available.");
          return;
        }

        bool authenticated = await auth.authenticate(
          localizedReason: 'Scan your fingerprint or face to login',
          options: const AuthenticationOptions(
            biometricOnly: false,
            useErrorDialogs: true,
            sensitiveTransaction: true,
            stickyAuth: true,
          ),
        );
        if (authenticated) {
          final tokenValue = uuid.v4();
          log("Authenticated successfully");
          try {
            secureStorage.write(key: 'token', value: tokenValue);
            Navigator.pushReplacementNamed(context, '/home');
          } catch (e) {
            log("Error on using token saving and accessing");
            _showMessage("No saved session. Please log in manually first.");
          }
        }
      } catch (e) {
        _showMessage("Authentication failed: $e");
      } finally {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Biometric Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            rootedCheck || jailbreak
                ? Center(
                  child: Text("Security Alert Device may be compromised."),
                )
                : ListView(
                  children: [
                    Icon(Icons.fingerprint, size: 100, color: Colors.teal),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        "Login using Biometrics",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: Icon(Icons.fingerprint),
                      label: Text("Login with Biometrics"),
                      onPressed:
                          _isAuthenticating
                              ? null
                              : _authenticateWithBiometrics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
