import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfileSearchScreen extends ConsumerStatefulWidget {
  const ProfileSearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends ConsumerState<ProfileSearchScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  late List<SearchUserModel> currentUsers;
  @override
  void initState() {
    // TODO: implement initState
    searchCtrl.addListener(() {
      final text = searchCtrl.text;
      updateResults(text);
    });
    currentUsers = [];
    super.initState();
  }

  void updateResults(String text) async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButton(
              onPressed: () {
                if (context.canPop())
                  context.pop();
                else
                  context.goNamed(RouteConstants.homescreen);
              },
            ),
            titleSpacing: 0,
            title: TextFormField(
              autofocus: true,
              controller: searchCtrl,
              cursorColor: Colors.blue,

              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(right: 20),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: null,
                disabledBorder: null,
                hint: Text(
                  "Search X",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
            actions: [
              SizedBox(width: 10),
              if (searchCtrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    searchCtrl.text = "";
                    updateResults("");
                  },
                  child: Icon(Icons.close, color: Colors.white),
                ),
              if (searchCtrl.text.isNotEmpty) SizedBox(width: 20),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey,
              width: double.infinity,
              height: 0.1,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: CurrentProfileSearchResults(searchQuery: searchCtrl.text),
            // child: ListView(children: [Text("data")]),
          ),
        ],
      ),
    );
  }
}

class CurrentSearchUser extends StatelessWidget {
  const CurrentSearchUser({super.key, required this.user});
  final SearchUserModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push("/profilescreen/${user.username}");
      },
      horizontalTitleGap: 10,
      enableFeedback: true,
      leading: CircleAvatar(
        backgroundImage: user.profileMedia.isNotEmpty
            ? CachedNetworkImageProvider(user.profileMedia)
            : AssetImage("assets/images/basic_user.jpeg"),
        radius: 22,
        backgroundColor: Colors.grey,
        onBackgroundImageError: (exception, stackTrace) => null,
      ),
      title: Flexible(
        child: Text(
          user.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      subtitle: Flexible(
        child: Text(
          "@${user.username}",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

class CurrentSearchUsersList extends StatelessWidget {
  const CurrentSearchUsersList({super.key, required this.users});
  final List<SearchUserModel> users;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),

      itemBuilder: (context, index) {
        return CurrentSearchUser(user: users[index]);
      },
      itemCount: users.length,
    );
  }
}

class CurrentProfileSearchResults extends ConsumerWidget {
  const CurrentProfileSearchResults({super.key, required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchQuery.isEmpty) return CurrentSearchUsersList(users: []);
    final asyncUsers = ref.watch(profileCurrentSearchProvider(searchQuery));
    return asyncUsers.when(
      data: (either) {
        return either.fold(
          (l) {
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                ref.refresh(profileCurrentSearchProvider(searchQuery));
              },
              child: ListView(children: [Center(child: Text(l.message))]),
            );
          },
          (users) {
            if (users.isEmpty)
              return Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    // TODO: go to search result
                  },
                  child: Text(
                    "Go to @${searchQuery}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            return CurrentSearchUsersList(users: users);
          },
        );
      },
      error: (err, _) {
        return ListView(children: [Center(child: Text(err.toString()))]);
      },
      loading: () {
        return Center(child: RefreshProgressIndicator());
      },
    );
  }
}
