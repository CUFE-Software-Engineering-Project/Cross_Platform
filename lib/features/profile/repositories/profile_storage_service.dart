import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';

class ProfileStorageService {
  static const String _userProfileBox = 'profileDataBox';

  late Box<ProfileModel> _profileBox;

  // Initialize Hive box
  Future<void> init() async {
    print("init -----------");
    _profileBox = await Hive.openBox<ProfileModel>(_userProfileBox);
    print(_profileBox.toString());
  }

  // Store profile data
  Future<void> storeProfileData(ProfileModel profile) async {
    await _profileBox.put(profile.username, profile);
  }

  // Get profile data by username
  ProfileModel? getProfileData(String username) {
    return _profileBox.get(username);
  }

  // Check if profile exists for username
  bool hasProfileData(String username) {
    return _profileBox.containsKey(username);
  }

  // Update specific fields for a profile
  Future<void> updateProfileData(String username, ProfileModel newData) async {
    await _profileBox.put(username, newData);
  }

  // Clear all profile data
  Future<void> clearAllProfiles() async {
    await _profileBox.clear();
  }

  // Close the box
  Future<void> close() async {
    print("close -----------");
    await _profileBox.close();
  }
}
