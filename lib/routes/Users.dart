import 'package:cached_network_image/cached_network_image.dart';
import 'package:darvester/database.dart';
import 'package:darvester/util.dart';
import 'package:drift/isolate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';

// Components
import '../components/MainDrawer.dart';

// Routes
import '../routes/Settings.dart';
import '../routes/User.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Set<DBUser?> users = {};
  int usersOffset = 0;
  static const int usersLimit = 50;
  bool reachedEnd = false;

  bool isLoading = true;
  int userCount = 0;

  Future<void> listUsers() async {
    DriftIsolate driftIsolate = Provider.of<DriftIsolate>(context, listen: false);
    DarvesterDatabase db = DarvesterDatabase(
      await driftIsolate.connect()
    );
    if ((await Preferences.instance.getString("databasePath")).isNotEmpty) {
      setState(() async {
        userCount = await db.getTableCount("users");
        List<DBUser?> users = await db.getUsers(limit: usersLimit, offset: usersOffset);
        if (users.isNotEmpty) {
          for (var user in users) {
            if (checkValidImage(user?.avatarUrl)) {
              precacheImage(CachedNetworkImageProvider(user?.avatarUrl ?? ""), context);
            }
          }
          this.users.addAll(users);
          usersOffset += usersLimit;
        } else {
          reachedEnd = true;
        }
        isLoading = false;
      });
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext builder) {
          return AlertDialog(
            title: const Text("Database path empty"),
            content: const Text("Database path is not set. Please set in Settings"),
            actions: <Widget>[
              TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
              TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (context) => const Settings())), child: const Text("Settings")),
            ],
          );
        },
      );
    }
  }

  Widget itemBuilder(int idx) {
    DBUser? user = users.elementAt(idx);
    return TextButton(
      style: const ButtonStyle(
        padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
        foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
        overlayColor: MaterialStatePropertyAll<Color>(Color(0x00000000)),
      ),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (context) => User(userID: user?.id ?? "")));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(180),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xff222222),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: FadeInImage(
                    fit: BoxFit.fill,
                    placeholder: const AssetImage('images/default_avatar.png'),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return const Image(
                        image: AssetImage('images/default_avatar.png'),
                        fit: BoxFit.fitWidth,
                      );
                    },
                    image: assetOrNetwork(user?.avatarUrl),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "${user?.name}\u200b#${user?.discriminator}",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 1000 ? 8 : 12,
                  ),
                  textAlign: TextAlign.center,
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    listUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      drawer: const MainDrawer(),
      body: isLoading
          ? const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xff333333),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x77111111),
                          offset: Offset(4, 20),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      height: double.infinity,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Showing ${enNumFormat.format(userCount).toString()} users",
                                style: const TextStyle(
                                  fontFamily: "UnboundedLight",
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => listUsers(),
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: LazyLoadScrollView(
                    onEndOfPage: () => listUsers(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(36),
                      itemCount: users.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 9 : 5,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                      ),
                      itemBuilder: (BuildContext context, idx) => itemBuilder(idx),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
