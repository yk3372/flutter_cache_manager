import 'dart:async';

import 'dart:collection';

typedef QueuedTask<T> = Future<T> Function();

class QueueManager {
  final int concurrentTasks;
  int _currentlyRunningTasks;

  final Queue<Completer> _queue = Queue();

  QueueManager(this.concurrentTasks);

  Future<T> runQueued<T>(QueuedTask<T> task) async {
    await _waitForQueue();
    try {
      var result = await task();
      return result;
    } finally{
      _releaseForQueue();
    }
  }

  Future _waitForQueue() async {
    if(_currentlyRunningTasks >= concurrentTasks){
      var completer = Completer();
      _queue.add(completer);
      await completer.future;
    }
    _currentlyRunningTasks++;
    return;
  }

  void _releaseForQueue(){
    _currentlyRunningTasks--;
    if(_queue.isNotEmpty){
      _queue.removeFirst().complete();
    }
  }
}