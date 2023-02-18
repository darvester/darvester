import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' show ExtensionSet;
import 'package:url_launcher/url_launcher.dart';

// Util
import '../util.dart';

const TextStyle bodyStyle = TextStyle(
  fontFamily: "UnboundedLight",
  fontSize: 14,
);

const TextStyle headerStyle = TextStyle(
  fontFamily: "UnboundedLight",
  fontSize: 22,
  color: Color(0xaa999999),
);

String? getNitroTier() {
  // TODO: implement nitro tier helper func
  return null;
}

class UserInfo extends StatelessWidget {
  final Map user;
  const UserInfo({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ABOUT ME",
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        MarkdownBody(
          onTapLink: (text, href, title) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Opening ${href ?? text} in browser"),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: const Duration(seconds: 3),
            ));
            launchUrl(Uri.parse(href ?? text));
          },
          onTapText: () {
            Clipboard.setData(ClipboardData(text: user["bio"]));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Copied bio to clipboard"),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: Duration(seconds: 1),
            ));
          },
          styleSheet: MarkdownStyleSheet(
            a: const TextStyle(
              fontFamily: "UnboundedLight",
            ),
            code: const TextStyle(
              fontFamily: "Courier",
              fontSize: 14
            ),
            blockSpacing: 0.1,
            textScaleFactor: 0.9,
          ),
          data: user["bio"].toString().replaceAll("\n", "\n\n"),
          selectable: false,
          extensionSet: ExtensionSet.gitHubWeb,
        ),
        const SizedBox(height: 16),
        const Text(
          "CREATED AT",
          style: TextStyle(fontSize: 12),
        ),
        TextButton(
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: "${user["created_at"] * 1000}"));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Copied timestamp to clipboard"),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: Duration(seconds: 1),
            ));
          },
          child: Text(
            DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(user["created_at"] * 1000)),
            style: const TextStyle(
              color: Color(0xaaffffff),
              fontFamily: "UnboundedLight",
              fontSize: 12
            ),
          ),
        ),
        const Divider(),

      ],
    );
  }
}

class User extends StatefulWidget {
  final String userID;

  const User({Key? key, required this.userID}) : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  Map user = {};
  bool isLoading = true;

  double bodyOpacity = 0;
  double headerOpacity = 0;

  Widget sectionHeader(String text, {bool alignRight = false}) {
    return Text(
      text,
      style: headerStyle,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      textScaleFactor: ScaleSize.textScaleFactor(context),
    );
  }

  Future<void> getUser() async {
    Preferences.instance.getString("databasePath").then((value) {
      if (value.isNotEmpty) {
        DarvesterDB.instance.getUser(widget.userID, context).then((r) {
          Map user;
          try {
            user = jsonDecode(r!["data"]);
            for (var url in [user["avatar_url"], user["banner"]]) {
              if (checkValidImage(url)) {
                precacheImage(CachedNetworkImageProvider(url), context);
              }

              setState(() {
                this.user = user;
                isLoading = false;
              });
            }
          } catch (_) {
            setState(() {
              isLoading = false;
            });
            showAlertDialog(context, "User not found", "Darvester has not yet encountered this user");
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showAlertDialog(context, "Database path missing", "Database path not set. Please configure this in Settings");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getUser().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          headerOpacity = 1;
        });
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          bodyOpacity = 1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Center(
        child: Scaffold(
          backgroundColor: const Color(0xff191919),
          appBar: AppBar(
            title: Text("${user["name"]}#${user["discriminator"]}"),
            backgroundColor: const Color(0xff222222),
          ),
          body: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xff111111),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      color: Color(0xff333333),
                                    ),
                                    child: FadeInImage(
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: const AssetImage('images/transparent.png'),
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return const Image(
                                          image: AssetImage('images/transparent.png'),
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      image: assetOrNetwork(user["banner"], fallbackUri: "images/transparent.png"),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 4,
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 22,
                                top: (MediaQuery.of(context).size.height > 800) ? 110 : 30,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(180),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 120,
                                    minWidth: 120,
                                  ),
                                  height: 120,
                                  width: 120,
                                  child: FadeInImage(
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage('images/default_avatar.png'),
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return const Image(
                                        image: AssetImage('images/default_avatar.png'),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    image: assetOrNetwork(user["avatar_url"], fallbackUri: "images/default_avatar.png"),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 100, right: 20, left: 160),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text("Badges"),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 24, bottom: 14),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("Copied username to clipboard"),
                                        behavior: SnackBarBehavior.floating,
                                        width: 300,
                                        duration: Duration(seconds: 1),
                                      ));
                                      Clipboard.setData(
                                          ClipboardData(text: "${user["name"]}#${user["discriminator"]}"));
                                    },
                                    style: const ButtonStyle(
                                      padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                                      foregroundColor: MaterialStatePropertyAll<Color>(Color(0xffffffff)),
                                    ),
                                    child: Text("${user["name"]}#${user["discriminator"]}"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("Copied user ID to clipboard"),
                                        behavior: SnackBarBehavior.floating,
                                        width: 300,
                                        duration: Duration(seconds: 1),
                                      ));
                                      Clipboard.setData(ClipboardData(text: widget.userID));
                                    },
                                    style: const ButtonStyle(
                                      padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                                    ),
                                    child: Text(widget.userID,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: "UnboundedLight",
                                          color: Color(0xaa777777),
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Expanded(
                                    child: TabBar(
                                      tabs: <Widget>[Tab(text: "User Info"), Tab(text: "Last Activities")],
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1000,
                                      maxHeight: 1000,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TabBarView(children: <Widget>[
                                        UserInfo(user: user),
                                        const Text("Last Activities"),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
