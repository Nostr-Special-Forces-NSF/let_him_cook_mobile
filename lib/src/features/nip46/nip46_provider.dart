import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/nip46/remote_signer_plugin.dart';
import 'package:let_him_cook/src/shared/providers/providers.dart';

final nip46Provider = Provider((ref) {
  final nostrService = ref.watch(nostrServicerProvider);
  return RemoteSignerPlugin(nostrService);
});