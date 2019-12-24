class ShowMedia {
    final List<Image> backdrops;
    final int id;
    final List<Image> posters;

    ShowMedia({this.backdrops, this.id, this.posters});

    factory ShowMedia.fromJson(Map<String, dynamic> json) {
        return ShowMedia(
            backdrops: json['backdrops'] != null ? (json['backdrops'] as List).map((i) => Image.fromJson(i)).toList() : null,
            id: json['id'],
            posters: json['posters'] != null ? (json['posters'] as List).map((i) => Image.fromJson(i)).toList() : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        if (this.backdrops != null) {
            data['backdrops'] = this.backdrops.map((v) => v.toJson()).toList();
        }
        if (this.posters != null) {
            data['posters'] = this.posters.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class Image {
    final double aspectRatio;
    final String filePath;
    final int height;
    final double voteAverage;
    final int voteCount;
    final int width;

    Image({this.aspectRatio, this.filePath, this.height, this.voteAverage, this.voteCount, this.width});

    factory Image.fromJson(Map<String, dynamic> json) {
        return Image(
            aspectRatio: json['aspect_ratio'],
            filePath: json['file_path'],
            height: json['height'],
            voteAverage: json['vote_average'],
            voteCount: json['vote_count'],
            width: json['width'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['aspect_ratio'] = this.aspectRatio;
        data['file_path'] = this.filePath;
        data['height'] = this.height;
        data['vote_average'] = this.voteAverage;
        data['vote_count'] = this.voteCount;
        data['width'] = this.width;
        return data;
    }
}