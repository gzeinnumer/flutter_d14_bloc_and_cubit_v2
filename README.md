# flutter_d14_bloc_and_cubit_v2

|<img src="/preview/preview1.png" width="300"/>|
|--|

- data_service.dart
```dart
import 'dart:convert';
import 'package:flutter_d14_bloc_and_cubit_v2/post.dart';
import 'package:http/http.dart' as http;

class DataService {
  final _baseUrl = 'jsonplaceholder.typicode.com';

  Future<List<Post>> getPost() async {
    try {
      final uri = Uri.https(_baseUrl, '/posts');
      // final uri = Uri.https(_baseUrl, '/postz'); //error sengaja
      final response = await http.get(uri);
      final json = jsonDecode(response.body) as List;
      final posts = json.map((postJson) => Post.fromJson(postJson)).toList();
      return posts;
    } on Error catch (e) {
      throw e;
    }
  }
}
```
- main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_d14_bloc_and_cubit_v2/post_bloc.dart';
import 'package:flutter_d14_bloc_and_cubit_v2/post_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PostBloc>(create: (context) => PostBloc()..add(PostInitEvent()))
        ],
        child: PostView(),
      ),
    );
  }
}
```
- post.dart
```dart
class Post {
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body']);
}
```
- post_bloc.dart
```dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_d14_bloc_and_cubit_v2/data_service.dart';
import 'package:flutter_d14_bloc_and_cubit_v2/post.dart';

//gzn_dart_blocclass_full_list_v1_essb
//EVENT-------------------------------------------------------------------------
abstract class PostEvent {}

class PostInitEvent extends PostEvent {}

class PostRefreshEvent extends PostEvent {}

//STATUS------------------------------------------------------------------------
abstract class PostStatus {
  const PostStatus();
}

class PostOnLoadingStatus extends PostStatus {
  const PostOnLoadingStatus();
}

class PostOnSuccessStatus extends PostStatus {
  final List<Post> list;

  PostOnSuccessStatus(this.list);
}

class PostOnFailedState extends PostStatus {
  final Error exception;

  PostOnFailedState(this.exception);
}

//STATE-------------------------------------------------------------------------
class PostState {
  final List<Post>? list;
  final PostStatus? status;

  const PostState({
    this.list = const <Post>[],
    this.status = const PostOnLoadingStatus(),
  });

  PostState copyWith({
    List<Post>? list,
    PostStatus? status,
  }) {
    return PostState(
      list: list ?? this.list,
      status: status ?? this.status,
    );
  }
}

//BLOC--------------------------------------------------------------------------
class PostBloc extends Bloc<PostEvent, PostState> {
  // final ExampleRepo repo;
  final _dataService = DataService();

  PostBloc() : super(const PostState());

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    if (event is PostInitEvent || event is PostRefreshEvent) {
      yield state.copyWith(status: const PostOnLoadingStatus());
      try {
        final res = await _dataService.getPost();
        // final res = <Post>[];
        yield state.copyWith(status: PostOnSuccessStatus(res));
      } on Error catch (e) {
        yield state.copyWith(status: PostOnFailedState(e));
      }
    }
  }
}
```
- post_view.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_d14_bloc_and_cubit_v2/post.dart';
import 'package:flutter_d14_bloc_and_cubit_v2/post_bloc.dart';

class PostView extends StatelessWidget {
  const PostView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post V2 EVENT STATE BLOC STATUS'),
      ),
      body: BlocBuilder<PostBloc, PostState>(builder: (context, state) {
        if (state.status is PostOnLoadingStatus) {
          print("LoadingPostStatus");

          return const Center(child: CircularProgressIndicator());
        } else if (state.status is PostOnSuccessStatus) {
          final c = state.status as PostOnSuccessStatus;
          return RefreshIndicator(
            onRefresh: () async {
              return BlocProvider.of<PostBloc>(context).add(PostRefreshEvent());
            },
            child: ListView.builder(
                itemCount: c.list.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(c.list[index].title.toString()),
                    ),
                  );
                }),
          );
        } else if (state.status is PostOnFailedState) {
          final c = state.status as PostOnFailedState;
          return Center(
            child: Text('Error occured: ${c.exception.toString()}'),
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
```

---

```
Copyright 2022 M. Fadli Zein
```