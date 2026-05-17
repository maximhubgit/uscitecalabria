import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uscitecalabria/logic/providers/auth_provider.dart';
import 'package:uscitecalabria/data/repositories/group_repository.dart';
import 'package:uscitecalabria/data/services/cache_service.dart';
import 'package:uscitecalabria/data/models/group.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(
    ref.watch(firebaseServiceProvider),
    CacheService(ref.watch(sharedPreferencesProvider)),
  );
});

final groupsProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupRepositoryProvider).getGroups();
});
