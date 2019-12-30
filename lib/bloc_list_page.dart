import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'info_bloc.dart';
import 'info_event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'info_state.dart';

class BlocListPage extends StatefulWidget {
  @override
  _BlocListPageState createState() => _BlocListPageState();
}

class _BlocListPageState extends State<BlocListPage> {
  InfoBloc _infoBloc;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _infoBloc = BlocProvider.of<InfoBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
      ),
      body: BlocBuilder<InfoBloc, InfoState>(
        builder: (context, state) {
          if (state is InfoLoadedState) {
            return EasyRefresh(
              child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                return CachedNetworkImage(imageUrl: state.models[index].cover);
              }),
              onRefresh: () async {
                _infoBloc.add(RefreshEvent());
              },
              onLoad: () async {
                _infoBloc.add(LoadMoreEvent());
              },
              firstRefresh: true,
            );
          } else {
            return Center(
              child: Text("Unkown"),
            );
          }
        },
      ),
    );
  }
}
