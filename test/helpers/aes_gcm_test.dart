// import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startpage/helpers/helpers.dart';

void main() {
  group('Encryption', () {
    String key = 'AVeryStrong32KeySecret0123456789';

    String aesDecrypted = '';
    String aesEncrypted = '';

    setUpAll(
      () => WidgetsFlutterBinding.ensureInitialized(),
    );

    test(
      'Encrypt',
      () async {
        // aesDecrypted = await rootBundle.loadString(
        //   'assets/json/config_personal.json',
        // );

        String encrypted = await AesGcm.encrypt(aesDecrypted, key: key);
        expect(encrypted, aesEncrypted);

        // print(encrypted);
      },
    );

    test(
      'Decrypt',
      () async {
        String decrypted = await AesGcm.decrypt(aesEncrypted, key: key);
        expect(decrypted, aesDecrypted);
      },
    );
  });
}
