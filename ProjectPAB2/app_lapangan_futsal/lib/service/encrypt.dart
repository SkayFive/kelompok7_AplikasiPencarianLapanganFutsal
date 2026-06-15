import 'package:encrypt/encrypt.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionHelper {
  static Future<void> _ensureKeyAndIv() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('key') || !prefs.containsKey('iv')) {
      final key = crypto.Key.fromSecureRandom(32);
      final iv = crypto.IV.fromSecureRandom(16);

      await prefs.setString('key', key.base64);
      await prefs.setString('iv', iv.base64);
    }
  }

  //ENCRYPT
  static Future<String> encrypt(String plainText) async {
    await _ensureKeyAndIv();
    final prefs = await SharedPreferences.getInstance();

    final key = crypto.Key.fromBase64(prefs.getString('key')!);
    final iv = crypto.IV.fromBase64(prefs.getString('iv')!);

    final encrypter = crypto.Encrypter(crypto.AES(key));

    return encrypter.encrypt(plainText, iv: iv).base64;
  }

  //DECRYPT
  static Future<String> decrypt(String encryptedText) async {
    await _ensureKeyAndIv();
    final prefs = await SharedPreferences.getInstance();

    final key = crypto.Key.fromBase64(prefs.getString('key')!);
    final iv = crypto.IV.fromBase64(prefs.getString('iv')!);

    final encrypter = crypto.Encrypter(crypto.AES(key));

    return encrypter.decrypt64(encryptedText, iv: iv);
  }
}