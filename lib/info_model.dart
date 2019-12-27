import 'package:equatable/equatable.dart';

class InfoModel  {
  String cover; //封面
  String title; //标题
  bool isNew; //是否是最新
  InfoModel({this.cover, this.title, this.isNew});

  InfoModel.fromJson(Map<String, dynamic> json) {
    title = json["title"]?.toString();
    cover = json["cover"]?.toString();
    isNew = json["is_new"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["title"] = title;
    data["cover"] = cover;
    data["is_new"] = isNew;
    return data;
  }

  static getInfoModelsFromJson(Map<String, dynamic> json) {
    if (json["subjects"] != null) {
      var v = json["subjects"];
      var arr0 = List<InfoModel>();
      v.forEach((v) {
        InfoModel model = InfoModel.fromJson(v);
        arr0.add(InfoModel.fromJson(v));
      });
      return arr0;
    }
    return [];
  }

//  @override
//  List<Object> get props => [title, cover];
}
