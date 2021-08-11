

class PlacePredictions {

  String? place_id;
  String? main_text;
  String? secondary_text;

  PlacePredictions({this.place_id, this.main_text, this.secondary_text});


  factory PlacePredictions.fromJson(Map<String, dynamic> json) =>
      PlacePredictions(
          main_text: json["structured_formatting"]["main_text"],
          place_id: json["place_id"],
          secondary_text: json["structured_formatting"]["secondary_text"]);

  // factory PlacePredictions.fromJson(Map<String, dynamic> json) {
  //   main_text = json["main_text"];
  //   place_id = json["place_id"];
  //   secondary_text = json["secondary_text"];
  // }

}
