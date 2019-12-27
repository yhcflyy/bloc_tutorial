import 'package:equatable/equatable.dart';
import 'info_model.dart';

//整个列表页的状态

abstract class InfoState extends Equatable {
  final bool isLoading;

  const InfoState({this.isLoading});

  @override
  List<Object> get props => [];
}

class InfoUnInitState extends InfoState{}

class InfoLoadingState extends InfoState{}

class InfoLoadedState extends InfoState{
  final List<InfoModel> models;
  final bool hasReachedMax;

  const InfoLoadedState({this.models,this.hasReachedMax});

  InfoLoadedState copyWith({List<InfoModel> models,bool hasReachedMax}){
    return InfoLoadedState(models: models??this.models,hasReachedMax:hasReachedMax??this.hasReachedMax);
  }

  @override
  // TODO: implement props
  List<Object> get props => [models,hasReachedMax];
}

class InfoErrorState extends InfoState{}
