import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/verifiers/web_event_verifier.dart';

EventVerifier createNostrEventVerifier({required bool isWeb}) {
  if (isWeb) {
    try {
      return WebEventVerifier();
    } on UnsupportedError {
      return Bip340EventVerifier();
    }
  }
  return RustEventVerifier();
}
