class HistoriqueRendezVous {
  final String id;
  final String titre;
  final String date;
  final String heure;
  final String lieu;
  final bool effectue;

  HistoriqueRendezVous({
    required this.id,
    required this.titre,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.effectue,
  });

  factory HistoriqueRendezVous.fromMap(String id, Map<String, dynamic> data) {
    return HistoriqueRendezVous(
      id: id,
      titre: data['titre'] ?? '',
      date: data['date'] ?? '',
      heure: data['heure'] ?? '',
      lieu: data['lieu'] ?? '',
      effectue: data['effectué'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'date': date,
      'heure': heure,
      'lieu': lieu,
      'effectué': effectue,
    };
  }
}
