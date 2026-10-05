import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_app/helpers/user_info.dart';
import 'package:klinik_app/service/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getUserID/getUsername null saat belum login, bukan string "null"',
      () async {
    expect(await UserInfo().getToken(), isNull);
    expect(await UserInfo().getUserID(), isNull);
    expect(await UserInfo().getUsername(), isNull);
  });

  test('login admin/admin menyimpan token', () async {
    final berhasil = await LoginService().login('admin', 'admin');

    expect(berhasil, isTrue);
    expect(await UserInfo().getToken(), 'admin');
    expect(await UserInfo().getUserID(), '1');
    expect(await UserInfo().getUsername(), 'admin');
  });

  test('login salah tidak menyimpan token', () async {
    final berhasil = await LoginService().login('admin', 'salah');

    expect(berhasil, isFalse);
    expect(await UserInfo().getToken(), isNull);
  });

  test('logout benar-benar menghapus token sebelum selesai', () async {
    await LoginService().login('admin', 'admin');

    await UserInfo().logout();

    expect(await UserInfo().getToken(), isNull);
    expect(await UserInfo().getUsername(), isNull);
  });
}
