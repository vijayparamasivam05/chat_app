class Note{
    String userId;
    int id;
    String title;
    String body;
    Note(this.userId, this.id, this.title, this.body);
    //Note(this.userId, this.id, this.title);
    Note.fromJson(Map<String, dynamic> json){
        userId = json['userId'];
        id = json['id'];
        title = json['title'];
        body = json['body'];
    }

}