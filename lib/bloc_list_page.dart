import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'info_bloc.dart';
import 'info_event.dart';

class BlocListPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
      ),
      body: BlocProvider(create: (context) => InfoBloc()..add(RefreshEvent()),
      child: EasyRefresh(child: null),),
    );
  }
}