class RoomModel {
  String id;
  String name;
  String measure;
  List<dynamic> cools;
  bool isReal;

  RoomModel(this.id, this.name, this.measure, this.cools)
      : isReal = false; //id == "7" ? true : false;
}
