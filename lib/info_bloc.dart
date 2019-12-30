import 'info_event.dart';
import 'info_state.dart';
import 'info_model.dart';
import 'package:bloc/bloc.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  int page = 0;

  InfoBloc();
  @override
  // TODO: implement initialState
  InfoState get initialState => InfoUnInitState();
  
  @override
  Stream<InfoState> mapEventToState(InfoEvent event) async* {
    final currentState = state;

    if (event is LoadMoreEvent && !_hasReachedMax(state)) {
      try {
        if (currentState is InfoUnInitState) {
          List<InfoModel> models = await getMovies(page);
          yield InfoLoadedState(models: models, hasReachedMax: false);
        }
        if (currentState is InfoLoadedState){
          page = page + 1;
          List<InfoModel> models = await getMovies(page);
          if (models.isEmpty){
            yield currentState.copyWith(hasReachedMax: true);
          }else{
            yield InfoLoadedState(models: currentState.models + models,hasReachedMax: false);
          }
        }
      } catch (_) {
        yield InfoErrorState();
      }
    } else if (event is RefreshEvent) {
      page = 0;
      List<InfoModel> models = await getMovies(0);
      yield InfoLoadedState(models: models, hasReachedMax: false);
    }
  }

  bool _hasReachedMax(InfoState state) {
    return (state is InfoLoadedState) && state.hasReachedMax;
  }

  Future<List<InfoModel>> getMovies(int page) async {
    print("请求page:"+page.toString());
    HttpClient httpClient = HttpClient();
    var param = {
      "type": "tv",
      "tag": "美剧",
      "sort": "recommend",
      "page_limit": "20",
      "page_start": (page * 20).toString()
    };
    var uri = new Uri.https('movie.douban.com', '/j/search_subjects', param);
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    List<InfoModel> models =
        InfoModel.getInfoModelsFromJson(jsonDecode(responseBody));
    return models;
  }
}
