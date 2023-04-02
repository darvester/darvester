import 'package:darvester/darvester/harvester_isolate.dart';
import 'package:darvester/darvester/isolate_message.dart';
import 'package:darvester/darvester/isolate_set.dart';
import 'package:darvester/database.dart';
import 'package:drift/isolate.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' show PieChart, PieChartData, PieChartSectionData;
import 'package:provider/provider.dart';

import '../components/MainDrawer.dart';
import '../util.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double numOfGuilds = 0;
  double numOfUsers = 0;
  bool databaseOpen = false;

  @override
  void initState() {
    super.initState();
    Preferences.instance.getString("databasePath").then((path) async {
      DriftIsolate driftIsolate = Provider.of<DriftIsolate>(context, listen: false);
      DarvesterDatabase db = DarvesterDatabase(await driftIsolate.connect());
      if (path.isNotEmpty) {
        db.getTableCount("guilds").then((n) => setState(() {
              numOfGuilds = n.toDouble();
            }));
        db.getTableCount("users").then((n) => setState(() {
              numOfUsers = n.toDouble();
            }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<HarvesterIsolate> isolateSet = HarvesterIsolateSet.instance.set;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Darvester'),
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 150,
                    maxWidth: MediaQuery.of(context).size.width / 2,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2a),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                "Database",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Users",
                                style: TextStyle(
                                  color: Color(0xff777777),
                                ),
                              ),
                            ),
                            Text(
                              enNumFormat.format(numOfUsers).toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: "UnboundedLight",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Guilds",
                                style: TextStyle(
                                  color: Color(0xff777777),
                                ),
                              ),
                            ),
                            Text(
                              enNumFormat.format(numOfGuilds).toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: "UnboundedLight",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: MediaQuery.of(context).size.width / 2,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2a),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                "Users",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Users",
                                style: TextStyle(
                                  color: Color(0xff777777),
                                ),
                              ),
                            ),
                            Text(
                              enNumFormat.format(numOfUsers).toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: "UnboundedLight",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Guilds",
                                style: TextStyle(
                                  color: Color(0xff777777),
                                ),
                              ),
                            ),
                            Text(
                              enNumFormat.format(numOfGuilds).toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: "UnboundedLight",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 400,
                    maxWidth: MediaQuery.of(context).size.width / 2,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2a),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                "Isolates",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        (isolateSet.isNotEmpty)
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: MediaQuery.of(context).size.width / 2,
                                ),
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: isolateSet.length.toDouble(),
                                        title: "Total",
                                      ),
                                      ...(isolateSet.where((element) => element.state == HarvesterIsolateState.started).isNotEmpty
                                          ? [
                                              PieChartSectionData(
                                                value: isolateSet.where((element) => element.state == HarvesterIsolateState.started).length.toDouble(),
                                                title: HarvesterIsolateState.started.printableStateShort,
                                              )
                                            ]
                                          : []),
                                      ...(isolateSet.where((element) => element.state == HarvesterIsolateState.stopped).isNotEmpty
                                          ? [
                                              PieChartSectionData(
                                                value: isolateSet.where((element) => element.state == HarvesterIsolateState.stopped).length.toDouble(),
                                                title: HarvesterIsolateState.stopped.printableStateShort,
                                              )
                                            ]
                                          : []),
                                    ],
                                  ),
                                ),
                              )
                            : const Expanded(
                                child: Center(
                                  child: Text(
                                    "No isolates spawned",
                                    style: TextStyle(
                                      color: Color(0xff777777),
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
          ],
        ),
      ),
    );
  }
}
