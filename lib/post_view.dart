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
