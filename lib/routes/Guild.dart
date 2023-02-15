import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// Util
import '../util.dart';

// Components
import '../components/GuildUsers.dart';

Logger logger = Logger(name: "guild");

const TextStyle bodyStyle = TextStyle(
  fontFamily: "UnboundedLight",
  fontSize: 14,
);

const TextStyle headerStyle = TextStyle(
  fontFamily: "UnboundedLight",
  fontSize: 22,
  color: Color(0xaa999999),
);

String getGuildNitroTier(int premiumTier) {
  switch (premiumTier) {
    case 0:
      return "Not boosted";
    case 1:
      return "Level 1";
    case 2:
      return "Level 2";
    case 3:
      return "Level 3";
    default:
      return "Not boosted";
  }
}

class Guild extends StatefulWidget {
  final String guildid;

  const Guild({Key? key, required this.guildid}) : super(key: key);

  @override
  State<Guild> createState() => _GuildState();
}

class _GuildState extends State<Guild> {
  Map guild = {};

  double bodyOpacity = 0;
  double headerOpacity = 0;

  Widget sectionHeader(String text, {bool alignRight = false}) {
    // noqa
    return Text(
      text,
      style: headerStyle,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      textScaleFactor: ScaleSize.textScaleFactor(context),
    );
  }

  @override
  void initState() {
    super.initState();

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

    Preferences.instance.getString("databasePath").then((value) {
      if (value.isNotEmpty) {
        DarvesterDB.instance.getGuild(widget.guildid, context, columns: ["data"]).then((r) {
          Map guild;
          try {
            guild = jsonDecode(r!["data"]);
            if (checkInvalidImage(guild["icon"])) {
              precacheImage(NetworkImage(guild["icon"]), context);
            }

            setState(() {
              this.guild = guild;
            });
          } on NetworkImageLoadException {
            showAlertDialog(context, "Guild missing",
                "Data is missing here. This shouldn't happen, but you should still report this.");
          }
        });
      } else {
        showAlertDialog(context, "Database path missing", "Database path not set. Please configure this in Settings");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: guild.isEmpty ? const CircularProgressIndicator() : Scaffold(
          backgroundColor: const Color(0xff111111),
          appBar: AppBar(
            title: Text(guild["name"]),
            backgroundColor: const Color(0xff222222),
          ),
          body: Stack(
            children: <Widget>[
              Opacity(
                opacity: 0.3,
                child: SizedBox(
                  width: double.infinity,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: const AssetImage('images/transparent.png'),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const Image(
                          image: AssetImage('images/transparent.png'),
                          fit: BoxFit.fitWidth,
                        );
                      },
                      image: assetOrNetwork(guild["splash_url"], fallbackUri: "images/transparent.png"),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 64, right: 64),
                      child: Column(
                        children: [
                          AnimatedOpacity(
                            opacity: headerOpacity,
                            duration: const Duration(seconds: 1),
                            child: Row(
                              // BEGIN icon, name
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: SizedBox(
                                      width: 128,
                                      child: FadeInImage(
                                        placeholder: const AssetImage('images/default_avatar.png'),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return const Image(
                                            image: AssetImage('images/default_avatar.png'),
                                          );
                                        },
                                        image: assetOrNetwork(guild["icon"]),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    guild["name"],
                                    style: const TextStyle(
                                      fontSize: 32,
                                    ),
                                    textScaleFactor: ScaleSize.textScaleFactor(context),
                                  ),
                                )
                              ],
                            ),
                          ), // END icon, name
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 32.0),
                              child: RichText(
                                text: TextSpan(
                                  text: "Guild",
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontFamily: "UnboundedLight",
                                    color: Color(0x55999999),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          "  with ${guild['member_count'] ?? 'unknown'} members, first seen on ${DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(guild["first_seen"] * 1000))}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: "UnboundedLight",
                                        color: Color(0x99cccccc),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: bodyOpacity,
                            duration: const Duration(milliseconds: 700),
                            child: Container(
                              // BEGIN main body
                              constraints: const BoxConstraints(minHeight: 300),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x11000000),
                                      offset: Offset(4, 6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                  color: const Color(0x66222222),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 48, top: 48),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // BEGIN description
                                            sectionHeader("Description"),
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(guild["description"] ?? "None", style: bodyStyle),
                                            ), // END Description
                                            // BEGIN Features
                                            sectionHeader("Features"),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xaa222222),
                                                  borderRadius: BorderRadius.circular(6.0),
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: const Color(0xaa000000),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(14.0),
                                                  child: Text(
                                                    guild["features"].join("\n") ?? "None",
                                                    style: const TextStyle(
                                                      fontFamily: "Courier",
                                                      fontSize: 14,
                                                      color: Color(0x77ffffff),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // END Features
                                          ],
                                        ),
                                      ),
                                    ), // END description
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 48, top: 48),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            // BEGIN owner
                                            sectionHeader("Owner", alignRight: true),
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 300,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: () {
                                                String? owner;
                                                try {
                                                  owner = guild["owner"]["name"];
                                                  return (owner != null)
                                                      ? TextButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            owner,
                                                            style: bodyStyle,
                                                          ),
                                                        )
                                                      : const Text(
                                                          "Unknown",
                                                          style: TextStyle(
                                                            fontFamily: "UnboundedLight",
                                                            fontSize: 12,
                                                          ),
                                                        );
                                                } catch (_) {
                                                  return const Text(
                                                    "Failed to deserialize",
                                                    style: TextStyle(
                                                      fontFamily: "UnboundedLight",
                                                      fontSize: 12,
                                                      color: Color(0x55ff3333),
                                                    ),
                                                  );
                                                }
                                              }(),
                                            ), // END Owner
                                            // BEGIN Nitro Tier
                                            sectionHeader("Boost Tier", alignRight: true),
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 300,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                getGuildNitroTier(guild["premium_tier"]),
                                                style: bodyStyle,
                                              ),
                                            ), // END Nitro Tier
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Members",
                              style: TextStyle(
                                fontSize: 36,
                                color: Color(0x77aaaaaa),
                              ),
                            ),
                          ),
                          GuildUsers(guildID: widget.guildid,),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
