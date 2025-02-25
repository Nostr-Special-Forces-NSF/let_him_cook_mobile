import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nip55/signer_plugin.dart';

final signerProvider = Provider((ref) {
  return SignerPlugin();
});
