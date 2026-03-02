part of 'helpers.dart';

class AesGcm {
  static Future<String> encrypt(
    String data, {
    String key = '',
  }) async {
    if (key.isEmpty) return '';

    // Convert the input data to bytes
    final plaintext = utf8.encode(data);
    final gcmKey = utf8.encode(key);

    // Generate a 12-byte nonce using Dart's Random class
    final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));

    // Initialize the AES-GCM encryption algorithm
    final algorithm = cryptography.AesGcm.with256bits();

    // Create a secret key using the provided key bytes
    final secretKey = cryptography.SecretKey(gcmKey);

    // Perform encryption
    final secretBox = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
    );

    return base64.encode(secretBox.concatenation());
  }

  static Future<String> decrypt(
    String encryptedText, {
    String key = '',
  }) async {
    if (key.isEmpty) return '';

    // Decode the Base64-encoded ciphertext
    final data = base64.decode(encryptedText);
    final gcmKey = utf8.encode(key);

    // Extract the nonce (first 12 bytes) and ciphertext (remaining bytes)
    const nonceSize = 12;
    if (data.length < nonceSize) throw ArgumentError('Ciphertext too short');

    final iv = data.sublist(0, 12);
    final ciphertext = data.sublist(12, data.length - 16);
    final mac = data.sublist(data.length - 16);

    // Initialize the AES-GCM decryption algorithm
    final algorithm = cryptography.AesGcm.with256bits();

    // Create a secret key using the provided key bytes
    final secretKey = cryptography.SecretKey(gcmKey);

    // Perform decryption
    final secretBox = cryptography.SecretBox(
      ciphertext,
      mac: cryptography.Mac(mac),
      nonce: iv,
    );

    final plaintext = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    // Return the decrypted text as a UTF-8 string
    return utf8.decode(plaintext);
  }
}
