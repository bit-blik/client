import 'package:ndk/ndk.dart';

EventVerifier createNostrEventVerifier({required bool isWeb}) {
  if (isWeb) {
    return Bip340EventVerifier();
  }
  return RustEventVerifier();
}
