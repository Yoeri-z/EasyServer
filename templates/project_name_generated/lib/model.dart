abstract class Model {
  Model() {
    throw Error();
  }
  factory Model.fromJson(Map<String, dynamic> json) {
    throw Error();
  }
  Map<String, dynamic> toJson();
}
class Note implements Model {
	String title;
	String content;
	String timestamp;


  Note({
		required this.title, 		required this.content, 		required this.timestamp, 
  });

  ///Transforms your model into a Map with a json like structure.
  @override
  Map<String, dynamic> toJson() {
    return {
			"title": title,
			"content": content,
			"timestamp": timestamp,

    };
  }

  ///Creates a model from a map that has a json like structure, if you use this function yourself be absolutely sure that your map has a proper format that has the same keys as calling toJson on this method.
  @override
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
			title: json["title"],
			content: json["content"],
			timestamp: json["timestamp"],

    );
  }
}