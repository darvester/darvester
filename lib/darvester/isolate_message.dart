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

  /// The isolate is in an unknown state.
  unknown,

  /// The isolate was removed from the [HarvesterIsolateSet]
  removed,
}

extension IsolateStateMessage on HarvesterIsolateState {
  String get printableStateShort {
    switch (this) {
      case HarvesterIsolateState.starting:
        return "Starting";
      case HarvesterIsolateState.started:
        return "Working";
      case HarvesterIsolateState.stopping:
        return "Stopping";
      case HarvesterIsolateState.stopped:
        return "Stopped";
      case HarvesterIsolateState.pausing:
        return "Pausing";
      case HarvesterIsolateState.paused:
        return "Pausing";
      case HarvesterIsolateState.crashed:
        return "Crashed";
      case HarvesterIsolateState.unknown:
        return "Unknown";
      case HarvesterIsolateState.removed:
        return "Removed";
    }
  }

  String get printableStateLong {
    switch (this) {
      case HarvesterIsolateState.starting:
        return "The isolate is starting Darvester";
      case HarvesterIsolateState.started:
        return "Darvester is harvesting on this isolate";
      case HarvesterIsolateState.stopping:
        return "The isolate is stopping Darvester";
      case HarvesterIsolateState.stopped:
        return "Darvester has stopped harvesting on this isolate";
      case HarvesterIsolateState.pausing:
        return "The isolate is pausing Darvester";
      case HarvesterIsolateState.paused:
        return "Darvester has been paused and is waiting to be resumed";
      case HarvesterIsolateState.crashed:
        return "Darvester has crashed. Please view the logs for more info";
      case HarvesterIsolateState.unknown:
        return "The isolate is in an unknown state";
      case HarvesterIsolateState.removed:
        return "The isolate was recently removed from the isolate set";
    }
  }
}
