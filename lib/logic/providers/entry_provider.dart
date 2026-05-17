import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uscitecalabria/logic/providers/auth_provider.dart';
import 'package:uscitecalabria/data/repositories/entry_repository.dart';
import 'package:uscitecalabria/data/services/cache_service.dart';
import 'package:uscitecalabria/data/models/entry.dart';

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(
    ref.watch(firebaseServiceProvider),
    CacheService(ref.watch(sharedPreferencesProvider)),
  );
});

final entriesProvider = StreamProvider<List<Entry>>((ref) {
  return ref.watch(entryRepositoryProvider).getEntries();
});
