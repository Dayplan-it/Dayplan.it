import 'package:dayplan_it/components/week_calander/src/utils/cache_stream.dart';
import 'package:flutter/material.dart';

/// [CacheStreamBuilder] work only with a [CacheStream]
class CacheStreamBuilder<T> extends StreamBuilder {
  final T? initialData;
  final CacheStream<T> cacheStream;
  final AsyncWidgetBuilder? cacheBuilder;

  CacheStreamBuilder(
      {required this.cacheStream,
      this.cacheBuilder,
      this.initialData,
      Key? key})
      : super(
            key: key,
            initialData: initialData,
            stream: cacheStream.stream!,

            /// Return [lastValue] of [cacheStream] if [snapshot] has no data or error
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if ((snapshot.hasError || !snapshot.hasData) &&
                  cacheStream.lastValue != null) {
                return cacheBuilder!(
                    context,
                    AsyncSnapshot.withData(
                        ConnectionState.done, cacheStream.lastValue));
              } else {
                return cacheBuilder!(context, snapshot);
              }
            });
}
