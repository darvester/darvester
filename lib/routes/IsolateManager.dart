import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

// Components
import '../components/MainDrawer.dart';
import '../components/IsolateCard.dart';

// Util
import '../util.dart';

// Classes
import '../darvester/harvester_isolate.dart';
import '../darvester/isolate_set.dart';

class Manager extends StatefulWidget {
  const Manager({Key? key}) : super(key: key);

  @override
  State<Manager> createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  final Logger logger = Logger(name: "manager");

  IsolateCard? generateIsolateCards(BuildContext _, int idx) {
    return IsolateCard(
      digest: HarvesterIsolateSet.instance.set.elementAt(idx).hash,
      key: ValueKey(HarvesterIsolateSet.instance.set.elementAt(idx).hash),
    );
  }

  Future<Digest> spawnHarvesterThread(String token) async {
    Digest hashedToken = md5.convert(utf8.encode(token));

    if (HarvesterIsolateSet.instance.get(hashedToken) == null) {
      logger.info("Spawned a new harvester isolate: ${hashedToken.toString()}");
      // TODO: check if context messenger logic needs to be a singleton across routes
      HarvesterIsolate hIsolate = HarvesterIsolate(token, context);
      setState(() {
        HarvesterIsolateSet.instance.add(hIsolate);
      });
    }
    return hashedToken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolate Manager'),
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff444444),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xaa000000),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 200,
                        ),
                        child: TextField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Token",
                          ),
                          onSubmitted: (String token) async {
                            // TODO: when inputting a token that was just removed, the isolate card will be stuck in the removed state until a route change
                            String msg = "Could not validate JWT token";
                            if (validateJwtDiscordToken(token)) {
                              Digest threadDigest = await spawnHarvesterThread(token);
                              msg = "Started ${threadDigest.toString()}";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: HarvesterIsolateSet.instance.set.isNotEmpty
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                      mainAxisExtent: 420,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                    ),
                    padding: const EdgeInsets.all(16),
                    itemCount: HarvesterIsolateSet.instance.set.length,
                    itemBuilder: generateIsolateCards,
                  )
                : const Center(
                    child: Text(
                      style: TextStyle(
                        color: Color(0xff888888),
                      ),
                      "No harvester isolates spawned",
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
