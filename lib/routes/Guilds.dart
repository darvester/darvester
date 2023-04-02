import 'package:darvester/database.dart';
import 'package:darvester/routes/Guild.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Util
import '../util.dart';

// Components
import '../components/MainDrawer.dart';

// Routes
import 'Settings.dart';

class Guilds extends StatefulWidget {
  const Guilds({Key? key}) : super(key: key);

  @override
  State<Guilds> createState() => _GuildsState();
}

class _GuildsState extends State<Guilds> {
  List<DBGuild?> guilds = [];
  bool isLoading = true;

  Future listGuilds() async {
    guilds.clear();
    if ((await Preferences.instance.getString("databasePath")).isNotEmpty) {
      guilds = await DarvesterDatabase.instance.getGuilds();
      if (guilds.isNotEmpty) {
        for (var guild in guilds) {
          precacheImage(NetworkImage(guild?.icon ?? ""), context);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext builder) {
            return AlertDialog(
              title: const Text("Guilds is empty"),
              content: const Text("Data is possibly missing here. This shouldn't happen, but you should report this."),
              actions: <Widget>[
                TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
                TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())), child: const Text("Settings")),
              ],
            );
          },
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext builder) {
          return AlertDialog(
            title: const Text("Database path empty"),
            content: const Text("Database path is not set. Please set in Settings"),
            actions: <Widget>[
              TextButton(onPressed: () => context.go("/"), child: const Text("Go back")),
              TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings())), child: const Text("Take me there")),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    listGuilds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guilds'),
      ),
      drawer: const MainDrawer(),
      body: isLoading
          ? const SizedBox(width: double.infinity, height: double.infinity, child: Center(child: CircularProgressIndicator()))
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
                                "Showing ${guilds.length} guilds",
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
                                onPressed: () => listGuilds(),
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
                  child: GridView.count(
                    padding: const EdgeInsets.all(36),
                    crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 7 : 4,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: guilds.map((e) {
                      return TextButton(
                        style: const ButtonStyle(
                          padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(0)),
                          foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                          overlayColor: MaterialStatePropertyAll<Color>(Color(0x00000000)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Guild(guildID: e?.id ?? "")));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48),
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
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: const AssetImage('images/default_avatar.png'),
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return const Image(
                                          image: AssetImage('images/default_avatar.png'),
                                          fit: BoxFit.fitWidth,
                                        );
                                      },
                                      image: assetOrNetwork(e?.icon),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    e?.name ?? "Unknown",
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
              ],
            ),
    );
  }
}
