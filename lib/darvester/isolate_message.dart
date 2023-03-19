/// Defines different types of [HarvesterIsolateMessage]
enum HarvesterIsolateMessageType {
  /// [stop] tells the harvester loop to stop processing entries.
  stop,

  /// [start] starts the harvester loop.
  start,

  /// [pause] pauses the harvester loop at the current task, allowing it to be resumed again.
  pause,

  /// [log] will send a message to the [HarvesterIsolate] stream.
  log,

  /// [alert] may send a popup toast to the UI.
  alert,

  /// [state] indicates the isolate has changed states.
  state
}

/// Represents a message in the [HarvesterIsolate] stream.
class HarvesterIsolateMessage {
  /// Defines [HarvesterIsolateMessageType] of this message.
  final HarvesterIsolateMessageType type;

  /// Contains the new [HarvesterIsolateState] the isolate has transitioned to.
  final HarvesterIsolateState? state;

  /// Contains message contents in [Map] or [String]. Can also be [null].
  final dynamic data;

  /// Instantiates a [HarvesterIsolateMessage] with a type and optional [data] or
  /// [HarvesterIsolateState] when changing states.
  HarvesterIsolateMessage(this.type, {this.data, this.state});
}

/// Represents the state of a [HarvesterIsolate].
enum HarvesterIsolateState {
  /// The isolate is starting.
  starting,

  /// The isolate has started and is running.
  started,

  /// The isolate has received a stop message and is stopping.
  stopping,

  /// The isolate is stopped.
  stopped,

  /// The isolate has received a pause message and is pausing the loop.
  pausing,

  /// The isolate is in a paused state and can be started again.
  paused,

  /// The isolate has crashed and may have outputted a stacktrace.
  crashed,
}
