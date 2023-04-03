import 'package:darvester/database.dart';
import "package:flutter/material.dart";
import "package:lazy_load_scrollview/lazy_load_scrollview.dart";
import 'package:provider/provider.dart';

import '../util.dart';

import '../routes/User.dart';

Logger logger = Logger(name: "GuildUsers");

class GuildUsers extends StatefulWidget {
  final String guildID;
  const GuildUsers({Key? key, required this.guildID}) : super(key: key);

  @override
  State<GuildUsers> createState() => _GuildUsersState();
}

class _GuildUsersState extends State<GuildUsers> {
  List<DBUser?> members = [];
  int membersOffset = 0;
  bool reachedEnd = false;
  bool isLoaded = false;
  static const int limit = 50;

  void loadMoreMembers() async {
    if (reachedEnd) {
      logger.debug("End of guild members reached, not getting more");
      return;
    }
    logger.debug("Trying to load another $limit (offset $membersOffset) more members for ${widget.guildID}...");
    DarvesterDatabase db = Provider.of<DriftDBPair>(context, listen: false).db;
    db.getGuildMembers(widget.guildID, limit, membersOffset).then((r) {
      setState(() {
        if (r.isNotEmpty) {
          members.addAll(r);
          membersOffset += limit;
        } else {
          reachedEnd = true;
        }
        isLoaded = true;
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
        child: (members.isEmpty && !isLoaded)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : LazyLoadScrollView(
                onEndOfPage: () => loadMoreMembers(),
                child: GridView.builder(
                  itemCount: members.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 7 : 4,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                  ),
                  padding: const EdgeInsets.all(36),
                  physics: const AlwaysScrollableScrollPhysics(), // alt: [ClampingScrollPhysics]
                  itemBuilder: (BuildContext context, idx) {
                    DBUser? member = members[idx];
                    return TextButton(
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                        foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        overlayColor: MaterialStatePropertyAll<Color>(Color(0x00000000)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (context) => User(userID: member?.id ?? "")));
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
                                    image: assetOrNetwork(member?.avatarUrl),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "${member?.name}\u200b#${member?.discriminator}",
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width > 1000 ? 8 : 12,
                                    color: const Color(0xaaffffff),
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
                  },
                ),
              ),
      ),
    );
  }
}
