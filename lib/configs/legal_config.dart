/// Public legal pages, kept in one place so the app, the store listing and the
/// Health Connect permission rationale all point at the same URL.
class LegalConfig {
  const LegalConfig._();

  /// Canonical privacy policy. Google Play and Health Connect both require a
  /// publicly reachable policy, and Health Connect additionally requires the
  /// app itself to be able to show it on request.
  static const String privacyPolicyUrl =
      'https://asctechsoft.com/privacy/policy-aquamind/';
}
