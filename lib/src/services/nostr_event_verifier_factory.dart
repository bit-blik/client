import 'package:ndk/ndk.dart';

import 'nostr_event_verifier_factory_stub.dart'
    if (dart.library.ui) 'nostr_event_verifier_factory_flutter.dart'
    as impl;

EventVerifier createNostrEventVerifier({required bool isWeb}) =>
    impl.createNostrEventVerifier(isWeb: isWeb);
