import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startpage/helpers/helpers.dart';

void main() {
  group('Encryption', () {
    String key = 'VeryStrong32CharsLengthStringKey';

    String aesDecrypted = 'Test';
    String aesEncrypted = '';

    setUpAll(
      () => WidgetsFlutterBinding.ensureInitialized(),
    );

    test(
      'Encrypt',
      () async {
        String encrypted = await AesGcm.encrypt(aesDecrypted, key: key);
        expect(encrypted, isNotEmpty);

        // printLongStringWithMarkers(encrypted);

        aesEncrypted = encrypted;
      },
    );

    test(
      'Decrypt',
      () async {
        String decrypted = await AesGcm.decrypt(aesEncrypted, key: key);
        expect(decrypted, aesDecrypted);

        // printLongStringWithMarkers(decrypted);
      },
    );
  });
}

void printLongStringWithMarkers(String text) {
  const int chunkSize = 512;
  int part = 1;
  for (int i = 0; i < text.length; i += chunkSize, part++) {
    int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
    // ignore: avoid_print
    print('<BeginPart$part>${text.substring(i, end)}<EndPart$part>');
  }
}
