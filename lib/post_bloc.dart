
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