import 'package:darvester/util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

// Components
import '../components/MainDrawer.dart';

// Routes
import '../routes/Settings.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Set users = {};
  int usersOffset = 0;
  static const int usersLimit = 50;
  bool reachedEnd = false;

  bool isLoading = true;
  int userCount = 0;

  Future listUsers() async {
    Preferences.instance.getString("databasePath").then((value) {
      if (value.isNotEmpty) {
        DarvesterDB.instance.getUsersCount().then((i) {
          setState(() {
            userCount = i;
          });
        });
        DarvesterDB.instance
            .getUsers(context,
                columns: ["data", "id", "name", "discriminator", "avatar_url"], limit: usersLimit, offset: usersOffset)
            .then(
          (users) {
            if (users != null) {
              if (users.isNotEmpty) {
                for (var user in users) {
                  precacheImage(NetworkImage(user["avatar_url"]), context);
                }
                setState(() {
                  this.users.addAll(users);
                  isLoading = false;
                });
                usersOffset += usersLimit;
              } else {
                reachedEnd = true;
              }
            } else {
              setState(() {
                isLoading = false;
              });
              showDialog(
                context: context,
                builder: (BuildContext builder) {
                  return AlertDialog(
                    title: const Text("Users is empty"),
                    content:
                        const Text("Data is possibly missing here. This shouldn't happen, but you should report this."),
                    actions: <Widget>[
                      TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
                      TextButton(
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())),
                          child: const Text("Settings")),
                    ],
                  );
                },
              );
            }
          },
        );
      } else {
        showAlertDialog(context, "Users is empty", "Could not load any content from the users database");
      }
    });
  }

  Widget itemBuilder(idx) {
    Map user = users.elementAt(idx);
    return TextButton(
      style: const ButtonStyle(
        padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
        foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
        overlayColor: MaterialStatePropertyAll<Color>(Color(0x00000000)),
      ),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => User(userID: user["id"].toString())));
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
                    image: assetOrNetwork(user["avatar_url"]),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "${user["name"]}\u200b#${user["discriminator"]}",
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
