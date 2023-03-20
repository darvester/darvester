import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../darvester/isolate_set.dart';
import '../darvester/isolate_message.dart';

class IsolateCard extends StatefulWidget {
  final Digest digest;
  const IsolateCard({Key? key, required this.digest}) : super(key: key);

  @override
  State<IsolateCard> createState() => _IsolateCardState();
}

class _IsolateCardState extends State<IsolateCard> {
  HarvesterIsolateMessage? lastMessage;

  @override
  void initState() {
    super.initState();
    // TODO: implement a change notifier when new messages are received from the isolate
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xff444444),
      ),
      child: Column(
        children: [
          Text(widget.digest.toString()),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xff333333),
                  ),
                  child: SelectableText(
                    style: const TextStyle(
                      fontFamily: "Courier New",
                    ),
                    HarvesterIsolateSet.instance
                            .get(widget.digest)
                            ?.messageQueue
                            .where((message) {
                              return message.type == HarvesterIsolateMessageType.log;
                            })
                            .map((e) => e.data.toString())
                            .join("\n") ??
                        "",
                  ),
                ),
              ),
            ],
          ),
          TextButton(
              onPressed: () {
                HarvesterIsolateSet.instance.get(widget.digest)?.sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.stop));
              },
              child: const Text("Stop"))
        ],
      ),
    );
  }
}
