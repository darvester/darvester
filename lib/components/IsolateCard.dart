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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xff444444),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(widget.digest.toString()),
          ),
          Row(
            children: [
              Expanded(
                child: AnimatedSize(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 100),
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
              ),
            ],
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
                      } : null,
                child: const Text("Start"),
              ),
              TextButton(
                onPressed: ([
                  HarvesterIsolateState.started,
                ]).any((e) => currentState == e)
                    ? () {
                        HarvesterIsolateSet.instance.get(widget.digest)?.sendPort.send(HarvesterIsolateMessage(HarvesterIsolateMessageType.stop));
                      } : null,
                child: const Text("Stop"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
