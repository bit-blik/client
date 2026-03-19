import 'nostr_cache_factory_io.dart'
    if (dart.library.html) 'nostr_cache_factory_web.dart'
    as impl;

Future<dynamic> createNostrCacheManager() => impl.createNostrCacheManager();
