part of frappe;

/// An `EventStream` represents a series of discrete events. They're like a `Stream` in Dart, but
/// extends its functionality with the methods found on [Reactable].
///
/// Event streams can be created from a property via [Property.asEventStream], or through one of
/// its constructor methods. If an event stream is created from a property, its first event will be
/// the property's current value.
///
/// An `EventStream` will inherit the behavior of the stream from which it originated. So if an event
/// stream was created from a broadcast stream, it can support multiple subscriptions. Likewise, if
/// an event stream was created from a single-subscription stream, only one subscription can be added
/// to it. Take a look at the [article](https://www.dartlang.org/articles/broadcast-streams/) on
/// single-subscription streams vs broadcast streams to learn more about their different behaviors.
///
/// Internally, properties are implemented as broadcast streams and can receive multiple subscriptions.
///
/// If you were to model text input using properties and streams, the individual key strokes would be
/// events, and the resulting text is a property.
abstract class Reactable<T, R extends Reactable<T, R>> extends Stream<T> {
  StreamController<T> _controller;

  @override
  bool get isBroadcast => _controller.stream.isBroadcast;

  /// Returns a new stream that wraps a standard Dart `Stream`.
  Reactable(Stream<T> stream) {
    _controller = _createControllerForStream(stream);
  }

  /// Returns a new single subscription stream that doesn't contain any events then completes.
  Reactable.empty() : this.fromIterable([]);

  /// Returns a new single subscription stream that contains a single event then completes.
  Reactable.fromValue(T value) : this.fromIterable([value]);

  /// Returns a new [Reactable] that contains events from an `Iterable`.
  Reactable.fromIterable(Iterable<T> iterable)
      : this(new Stream<T>.fromIterable(iterable));

  /// Returns a new [Reactable] that contains a single event of the completed [future].
  Reactable.fromFuture(Future<T> future)
      : this(new Stream<T>.fromFuture(future));

  /// Creates a stream that repeatedly emits events at period intervals.
  ///
  /// The event values are computed by invoking `computation`. The argument to this
  /// callback is an integer that starts with 0 and is incremented for every event.
  ///
  /// If computation is omitted the event values will all be `null`.
  Reactable.periodic(Duration period, T computation(int count))
      : this(new Stream<T>.periodic(period, computation));

  StreamController<T> _createControllerForStream(Stream<T> stream) {
    StreamSubscription subscription;

    void onListen() {
      subscription = stream.listen(_controller.add,
          onDone: _controller.close, onError: _controller.addError);
    }

    void onCancel() {
      subscription.cancel();
    }

    return stream.isBroadcast
        ? new StreamController.broadcast(
            onListen: onListen, onCancel: onCancel, sync: true)
        : new StreamController(
            onListen: onListen, onCancel: onCancel, sync: true);
  }

  // Overrides

  R asBroadcastStream(
      {void onListen(StreamSubscription<T> subscription),
      void onCancel(StreamSubscription<T> subscription)}) {
    return _create /*<T>*/ (
        super.asBroadcastStream(onListen: onListen, onCancel: onCancel));
  }

  Reactable /*=R2*/ _create /*<T2, R2 extends Reactable<T2, R2>>*/ (
      Stream /*<T2>*/ stream);

  R asEventStream() => this;

  /// Returns a [Property] where the first value will be the next value from this stream.
  Property<T> asProperty() => new Property.fromStream(this);

  /// Returns a [Property] where the first value will be the [initialValue], and values
  /// after that will be the values from this stream.
  Property<T> asPropertyWithInitialValue(T initialValue) =>
      new Property.fromStreamWithInitialValue(initialValue, this);

  EventStream /*<R>*/ asyncExpand /*<R>*/ (Stream /*<R>*/ convert(T event)) =>
      _create /*<R>*/ (super.asyncExpand /*<R>*/ (convert));

  EventStream /*<R>*/ asyncMap /*<R>*/ (/*=R*/ convert(T event)) =>
      _create /*<R>*/ ((super.asyncMap /*<R>*/ (convert)));

  R bufferWhen(Stream<bool> toggle) => transform(new BufferWhen(toggle));

  EventStream combine(Stream other, Object combiner(T a, b)) =>
      transform(new Combine(other, combiner));

  EventStream concat(Stream other) => transform(new Concat<T>(other));

  EventStream concatAll() => transform(new ConcatAll());

  R debounce(Duration duration) => transform(new Debounce<T>(duration));

  R delay(Duration duration) => transform(new Delay<T>(duration));

  R distinct([bool equals(T previous, T next)]) =>
      _create /*<T>*/ (super.distinct(equals));

  R doAction(void onData(T value), {Function onError, void onDone()}) =>
      transform(new DoAction(onData, onError: onError, onDone: onDone));

  EventStream expand(Iterable convert(T value)) =>
      _create /*<T>*/ (super.expand(convert));

  EventStream flatMap(Stream convert(T event)) =>
      transform(new FlatMap(convert));

  EventStream /*<R>*/ flatMapLatest /*<R>*/ (Mapper /*<T, R>*/ convert) {
    print(convert.runtimeType);
    final flatMapLatest = new FlatMapLatest<T, Object /*=R*/ >(convert);
    print(flatMapLatest.runtimeType);
    final r = transform /*<R>*/ (flatMapLatest);
    print(r.runtimeType);

    return r;
  }

  EventStream /*<R>*/ flatMapLatest2 /*<R>*/ (Stream /*<R>*/ convert(T event)) {
    print(convert.runtimeType);
    final flatMapLatest = new FlatMapLatest<T, Object /*=R*/ >(convert);
    print(flatMapLatest.runtimeType);
    final r = transform /*<R>*/ (flatMapLatest);
    print(r.runtimeType);

    return r;
  }

  R handleError(Function onError, {bool test(error)}) =>
      _create /*<T>*/ (super.handleError(onError, test: test));

  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  EventStream /*<R>*/ map /*<R>*/ (/*=R*/ convert(T event)) =>
      _create /*<R>*/ (super.map(convert));

  EventStream /*<R>*/ merge /*<R>*/ (Stream other) =>
      transform /*<R>*/ (new Merge /*<dynamic, R>*/ (other));

  EventStream mergeAll() => transform(new MergeAll());

  EventStream<bool> not() => super.not();

  R sampleOn(Stream trigger) => transform(new SampleOn(trigger));

  R sampleEachPeriod(Duration duration) =>
      transform(new SamplePeriodically(duration));

  EventStream /*<R>*/ scan /*<R>*/ (
          /*=R*/ initialValue, /*=R*/ combine(/*=R*/ value, T element)) =>
      transform /*<R>*/ (new Scan /*<T, R>*/ (initialValue, combine));

  EventStream selectFirst(Stream other) => transform(new SelectFirst(other));

  R skip(int count) => _create /*<T>*/ (super.skip(count));

  R skipWhile(bool test(T element)) => _create /*<T>*/ (super.skipWhile(test));

  R skipUntil(Stream signal) => transform(new SkipUntil(signal));

  EventStream startWith(value) => transform(new StartWith(value));

  EventStream startWithValues(Iterable values) =>
      transform(new StartWith<T>.many(values));

  R take(int count) => _create /*<T>*/ (super.take(count));

  R takeUntil(Stream signal) => transform(new TakeUntil(signal));

  R takeWhile(bool test(T element)) => _create /*<T>*/ (super.takeWhile(test));

  EventStream timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) =>
      _create /*<T>*/ (super.timeout(timeLimit, onTimeout: onTimeout));

  EventStream /*<R>*/ transform /*<R>*/ (
          StreamTransformer<T, dynamic /*=R*/ > streamTransformer) =>
      _create /*<R>*/ (super.transform /*<R>*/ (streamTransformer));

  R when(Stream<bool> toggle) => transform(new When(toggle));

  R where(bool test(T event)) => _create /*<T>*/ (super.where(test));

  EventStream zip(Stream other, Combiner combiner) =>
      transform(new Zip<T, dynamic, dynamic>(other, combiner));
}
