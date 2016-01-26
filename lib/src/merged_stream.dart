part of frappe;

class _MergedStream<T> extends Stream<T> {
  Iterable<Stream<T>> _streams;

  _MergedStream(Iterable<Stream<T>> streams) :
    _streams = streams;

  @override
  StreamSubscription<T> listen(void onData(event), {Function onError, void onDone(), bool cancelOnError}) {
    var subscriptions = <StreamSubscription<T>>[];
    var doneCounter = 0;

    var controller = new StreamController<T>(
        onCancel: () => subscriptions.forEach((subscription) => subscription.cancel()),
        onPause: () => subscriptions.forEach((subscription) => subscription.pause()),
        onResume: () => subscriptions.forEach((subscription) => subscription.resume()));

    void checkIfDone() {
      doneCounter++;

      if (doneCounter == subscriptions.length) {
        controller.close();
      }
    }

    void handleError(Object error, StackTrace stackTrace) {
      controller.addError(error, stackTrace);
    }

    void handleErrorAndCancel(Object error, StackTrace stackTrace) {
      controller.addError(error, stackTrace);
      subscriptions.forEach((subscription) => subscription.cancel());
    }

    for (var stream in _streams) {
      subscriptions.add(stream.listen(
          (event) => controller.add(event),
          onDone: checkIfDone,
          onError: cancelOnError == true ? handleErrorAndCancel : handleError));
    }

    if (subscriptions.isEmpty) {
      controller.close();
    }

    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}