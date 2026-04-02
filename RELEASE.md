# iOS

- in macos do `flutter build ipa`

- submit to app store connect using transporter or xcode

- submit new version for review in app store connect

- `curl -X GET  https://api.altstore.io/adps/<apd-id>` (get the APD id from app store connect -> iOS History)

- fetch the package from the json field `downloadURL`

- unzip it into bitblik.app web html root / ios/<version-number>

- add version to https://bitblik.app/.well-known/sources/alt-store-source.json (not the one in git, but in the VPS /ios/...)

# Android

todo

# Web

todo