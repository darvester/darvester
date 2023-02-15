import "package:flutter/material.dart";
import "package:lazy_load_scrollview/lazy_load_scrollview.dart";

import '../util.dart';

class GuildUsers extends StatefulWidget {
  final String guildID;
  const GuildUsers({Key? key, required this.guildID}) : super(key: key);

  @override
  State<GuildUsers> createState() => _GuildUsersState();
}

class _GuildUsersState extends State<GuildUsers> {
  List<Map> members = [];
  int membersOffset = 0;

  void loadMoreMembers() {
    DarvesterDB.instance.getGuildMembers(
        widget.guildID,
        context,
        offset: membersOffset
    ).then((r) {
      setState(() {
        if (r != null) {
          members.addAll(r);
          membersOffset += 20;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    loadMoreMembers();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x55333333),
          borderRadius: BorderRadius.circular(12),
        ),
        child: (members.isEmpty) ? const Center(
          child: CircularProgressIndicator(),
        ) : LazyLoadScrollView(
          onEndOfPage: () { loadMoreMembers(); },
          child: GridView.count(
            padding: const EdgeInsets.all(36),
            crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 7 : 4,
            physics: const AlwaysScrollableScrollPhysics(), // alt: [ClampingScrollPhysics]
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: members.map((member) {
              return TextButton(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                  foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                  overlayColor: MaterialStatePropertyAll<Color>(Color(0x00000000)),
                ),
                onPressed: () {
                  // Navigator.of(context)
                  //     .push(MaterialPageRoute(builder: (context) => Guild(guildid: e["id"].toString())));
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
                              image: assetOrNetwork(member["avatar_url"]),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            member["name"],
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
            }).toList(),
          ),
        ),
      ),
    );
  }
}
