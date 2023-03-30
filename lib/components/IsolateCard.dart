import 'package:crypto/crypto.dart';
import 'package:darvester/darvester/harvester_isolate.dart';
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
  late HarvesterIsolateState currentState;

  void messageQueueListener() {
    HarvesterIsolateState? lastState = HarvesterIsolateSet.instance.get(widget.digest)?.messageQueue.last.state;
    lastState != null ? currentState = lastState : null;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    HarvesterIsolateSet.instance.get(widget.digest)?.messageQueue.removeListener(messageQueueListener);
    HarvesterIsolateSet.instance.get(widget.digest)?.messageQueue.addListener(messageQueueListener);
    currentState = HarvesterIsolateSet.instance.get(widget.digest)?.state ?? HarvesterIsolateState.unknown;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 520,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xff444444),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xffaaaaaa),
            ),
            widget.digest.toString().substring(0, 8),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                    currentState.printableStateShort
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xffcccccc),
                      ),
                      currentState.printableStateLong
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xff333333),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 410,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: SelectableText(
                    style: const TextStyle(
                      fontFamily: "Courier New",
                    ),
                    // filter for log messages in the message queue and print those out to this console display
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
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: ([
                  HarvesterIsolateState.stopped,
                  HarvesterIsolateState.paused,
                  HarvesterIsolateState.crashed,
                ]).any((e) => currentState == e)
                    ? () {
                        HarvesterIsolateSet.instance.get(widget.digest)?.sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.start));
                      }
                    : null,
                child: const Text("Start"),
              ),
              TextButton(
                onPressed: ([
                  HarvesterIsolateState.started,
                ]).any((e) => currentState == e)
                    ? () {
                        HarvesterIsolateSet.instance.get(widget.digest)?.sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.stop));
                      }
                    : null,
                child: const Text("Stop"),
              ),
              TextButton(
                onPressed: ([
                  HarvesterIsolateState.stopped,
                  HarvesterIsolateState.crashed
                ]).any((e) => currentState == e) ? () {
                  HarvesterIsolate? isolate = HarvesterIsolateSet.instance.get(widget.digest);
                  if (isolate != null) {
                    isolate.isolate.kill(priority: 0);
                  }
                  // TODO: fix removing cards with index 0, index 1 inherits state from index 0 card
                  setState(() {
                    HarvesterIsolateSet.instance.set.remove(isolate);
                  });
                } : null,
                child: const Text("Remove"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
