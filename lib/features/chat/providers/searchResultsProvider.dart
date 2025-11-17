import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';

final searchResultsProvider = StateProvider<List<UserSearchModel>>((ref) => []);
