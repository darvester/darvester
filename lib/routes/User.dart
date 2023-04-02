import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:darvester/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' show ExtensionSet;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class UserConnection extends StatelessWidget {
  final Map connection;
  const UserConnection({Key? key, required this.connection}) : super(key: key);

  String? getUrl() {
    switch (connection["type"][0].toString().toLowerCase()) {
      case "reddit":
        return "https://reddit.com/u/${connection["name"]}";
      case "spotify":
        return "https://open.spotify.com/user/${connection["id"]}";
      // case "steam":
      //   return "https://steamcommunity.com/id/${connection["id"]}";
      case "twitch":
        return "https://twitch.tv/${connection["name"]}";
      case "twitter":
        return "https://twitter.com/${connection["name"]}";
      case "youtube":
        return "https://youtube.com/channel/${connection["id"]}";
      case "instagram":
        return "https://instagram.com/${connection["name"]}";
      case "tiktok":
        return "https://tiktok.com/@${connection["name"]}";
      case "github":
        return "https://github.com/${connection["name"]}";
      default:
        return null;
    }
  }

  Widget getIcon(String type) {
    switch (type.toLowerCase()) {
      case "battlenet":
        return const Tooltip(
          message: "Battle.net",
          child: FaIcon(
            FontAwesomeIcons.gamepad,
            size: 14,
          ),
        );
      case "battle_net":
        return const Tooltip(
          message: "Battle.net",
          child: FaIcon(
            FontAwesomeIcons.gamepad,
            size: 14,
          ),
        );
      case "ebay":
        return const Tooltip(
          message: "eBay",
          child: FaIcon(
            FontAwesomeIcons.ebay,
            size: 14,
          ),
        );
      case "epicgames":
        return const Tooltip(
          message: "Epic Games",
          child: FaIcon(
            FontAwesomeIcons.gamepad,
            size: 14,
          ),
        );
      case "facebook":
        return const Tooltip(
          message: "Facebook",
          child: FaIcon(
            FontAwesomeIcons.facebook,
            size: 14,
          ),
        );
      case "github":
        return const Tooltip(
          message: "GitHub",
          child: FaIcon(
            FontAwesomeIcons.github,
            size: 14,
          ),
        );
      case "instagram":
        return const Tooltip(
          message: "Instagram",
          child: FaIcon(
            FontAwesomeIcons.instagram,
            size: 14,
          ),
        );
      case "leagueoflegends":
        return const Tooltip(
          message: "League of Legends",
          child: FaIcon(
            FontAwesomeIcons.gamepad,
            size: 14,
          ),
        );
      case "paypal":
        return const Tooltip(
          message: "PayPal",
          child: FaIcon(
            FontAwesomeIcons.paypal,
            size: 14,
          ),
        );
      case "playstation":
        return const Tooltip(
          message: "PlayStation Network",
          child: FaIcon(
            FontAwesomeIcons.playstation,
            size: 14,
          ),
        );
      case "reddit":
        return const Tooltip(
          message: "Reddit",
          child: FaIcon(
            FontAwesomeIcons.reddit,
            size: 14,
          ),
        );
      case "riotgames":
        return const Tooltip(
          message: "Riot Games",
          child: FaIcon(
            FontAwesomeIcons.gamepad,
            size: 14,
          ),
        );
      case "spotify":
        return const Tooltip(
          message: "Spotify",
          child: FaIcon(
            FontAwesomeIcons.spotify,
            size: 14,
            color: Color(0xff44ff44),
          ),
        );
      case "skype":
        return const Tooltip(
          message: "Skype",
          child: FaIcon(
            FontAwesomeIcons.skype,
            size: 14,
          ),
        );
      case "steam":
        return const Tooltip(
          message: "Steam",
          child: FaIcon(
            FontAwesomeIcons.steam,
            size: 14,
            color: Color(0xff394a8d),
          ),
        );
      case "tiktok":
        return const Tooltip(
          message: "TikTok",
          child: FaIcon(
            FontAwesomeIcons.tiktok,
            size: 14,
          ),
        );
      case "twitch":
        return const Tooltip(
          message: "Twitch",
          child: FaIcon(
            FontAwesomeIcons.twitch,
            size: 14,
            color: Color(0xff6441a5),
          ),
        );
      case "twitter":
        return const Tooltip(
          message: "Twitter",
          child: FaIcon(
            FontAwesomeIcons.twitter,
            size: 14,
          ),
        );
      case "xbox":
        return const Tooltip(
          message: "Xbox",
          child: FaIcon(
            FontAwesomeIcons.xbox,
            size: 14,
            color: Color(0xff00aa00),
          ),
        );
      case "youtube":
        return const Tooltip(
          message: "YouTube",
          child: FaIcon(
            FontAwesomeIcons.youtube,
            size: 14,
            color: Color(0xffff0000),
          ),
        );
      default:
        return Tooltip(
          message: type,
          child: const FaIcon(
            FontAwesomeIcons.user,
            size: 14,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration containerDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xaaffffff),
        ));

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: containerDecoration,
      constraints: const BoxConstraints(
        maxWidth: 300,
      ),
      padding: const EdgeInsets.all(8),
      child: TextButton(
        style: const ButtonStyle(
          foregroundColor: MaterialStatePropertyAll<Color>(Color(0xffffffff)),
          padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
        ),
        onPressed: () {
          String? url = getUrl();
          if (url != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Opening ${connection["name"]} in browser"),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: const Duration(seconds: 3),
            ));
            launchUrl(Uri.parse(url));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Copied \"${connection["name"]}\""),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: const Duration(seconds: 1),
            ));
            Clipboard.setData(ClipboardData(text: connection["name"]));
          }
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: getIcon(connection["type"][0]),
            ),
            Expanded(
              child: Text(
                connection["name"],
                style: const TextStyle(fontFamily: "UnboundedLight", fontSize: 12),
              ),
            ),
            getUrl() != null
                ? const FaIcon(
                    FontAwesomeIcons.arrowUpRightFromSquare,
                    size: 14,
                  )
                : const FaIcon(
                    FontAwesomeIcons.copy,
                    size: 14,
                  )
          ],
        ),
      ),
    );
  }
}

class UserConnections extends StatelessWidget {
  final List connections;
  const UserConnections({Key? key, required this.connections}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...(() {
                List<Widget> cells = [];
                for (var connection in connections) {
                  if (connections.indexOf(connection) % 2 == 0) {
                    cells.add(UserConnection(connection: connection));
                  }
                }
                return cells;
              }())
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...(() {
                List<Widget> cells = [];
                for (var connection in connections) {
                  if (connections.indexOf(connection) % 2 == 1) {
                    cells.add(UserConnection(connection: connection));
                  }
                }
                return cells;
              }())
            ],
          ),
        ),
      ],
    );
  }
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
          styleSheet: MarkdownStyleSheet(
            a: const TextStyle(
              fontFamily: "UnboundedLight",
              color: Color(0xaaaaaaff),
            ),
            p: const TextStyle(
              fontFamily: "UnboundedLight",
              color: Color(0xaaffffff),
            ),
            code: const TextStyle(
              fontFamily: "Courier",
              fontSize: 14,
              color: Color(0xeeffffff),
              backgroundColor: Color(0xaa444444),
            ),
            blockSpacing: 0.1,
            textScaleFactor: 0.9,
          ),
          data: user["bio"].toString().isEmpty ? "None" : user["bio"].toString().replaceAll("\n", "\n\n"),
          selectable: true,
          extensionSet: ExtensionSet.gitHubFlavored,
        ),
        const SizedBox(height: 16),
        const Text(
          "CREATED AT",
          style: TextStyle(fontSize: 12),
        ),
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: "${user["created_at"] * 1000}"));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Copied timestamp to clipboard"),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: Duration(seconds: 1),
            ));
          },
          child: Text(
            DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(user["created_at"] * 1000)),
            style: const TextStyle(color: Color(0xaaffffff), fontFamily: "UnboundedLight", fontSize: 12),
          ),
        ),
        const Divider(),
        const Text(
          "CONNECTIONS",
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(
            minHeight: 30,
          ),
          child: UserConnections(
            connections: user["connected_accounts"],
          ),
        ),
        const SizedBox(height: 16),
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
  late DBUser user;
  bool isLoading = true;

  int tabIndex = 0;

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
    if ((await Preferences.instance.getString("databasePath")).isNotEmpty) {
      setState(() async {
        user = await DarvesterDatabase.instance.getUser(widget.userID);
        for (String? url in [user.avatarUrl, user.banner]) {
          if (checkValidImage(url)) {
            precacheImage(CachedNetworkImageProvider(url ?? ""), context);
          }
        }
        isLoading = false;
      });
    } else {
      showAlertDialog(context, "Database path missing", "Database path not set. Please configure this in Settings");
    }
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
            title: Text("${user.name}#${user.discriminator}"),
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
                                      image: assetOrNetwork(user.banner, fallbackUri: "images/transparent.png"),
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
                                    image: assetOrNetwork(user.avatarUrl, fallbackUri: "images/default_avatar.png"),
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
                                      Clipboard.setData(ClipboardData(text: "${user.name}#${user.discriminator}"));
                                    },
                                    style: const ButtonStyle(
                                      padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                                      foregroundColor: MaterialStatePropertyAll<Color>(Color(0xffffffff)),
                                    ),
                                    child: Text("${user.name}#${user.discriminator}"),
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
                                    child: Text(
                                      widget.userID,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: "UnboundedLight",
                                        color: Color(0xaa777777),
                                      ),
                                    ),
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
                                children: [
                                  Expanded(
                                    child: TabBar(
                                      onTap: (index) {
                                        setState(() {
                                          tabIndex = index;
                                        });
                                      },
                                      tabs: const <Widget>[Tab(text: "User Info"), Tab(text: "Last Activities")],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: Builder(
                                    builder: (_) {
                                      return AnimatedCrossFade(
                                        firstChild: UserInfo(user: user.toJson()),
                                        secondChild: const Placeholder(),
                                        crossFadeState: tabIndex == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                        duration: const Duration(milliseconds: 300),
                                      );
                                    },
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
