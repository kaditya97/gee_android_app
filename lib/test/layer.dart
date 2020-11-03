class Layer {
  final String url,
      name,
      attribution;
  final int id;

  Layer({
      this.id,
      this.url,
      this.name,
      this.attribution});

  factory Layer.fromJson(Map<String, dynamic> json) => Layer(
    id: json["id"],
    url: json["url"] ,
    name: json["name"],
    attribution: json["attribution"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "name": name,
    "attribution": attribution
  };
}