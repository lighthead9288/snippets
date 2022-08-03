class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String imageUrl;
  final DateTime lastSeen;
  final String role;
  final List<String> quizesIds;

  User(this.id, this.name, this.surname, this.email, this.imageUrl, this.lastSeen, this.role, this.quizesIds);

}