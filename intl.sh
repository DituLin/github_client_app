flutter pub pub run intl_translation:extract_to_arb --output-dir=i10n-arb lib/i10n/localization_intl.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/i10n --no-use-deferred-loading lib/i10n/localization_intl.dart i10n-arb/intl_*.arb
