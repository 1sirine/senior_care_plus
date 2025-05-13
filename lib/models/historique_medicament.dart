class HistoriqueMedicament {
  final String id;
  final String nom;
  final String date;
  final String heure;
  final int quantite;
  final bool pris;

  HistoriqueMedicament({
    required this.id,
    required this.nom,
    required this.date,
    required this.heure,
    required this.quantite,
    required this.pris,
  });

  factory HistoriqueMedicament.fromMap(String id, Map<String, dynamic> data) {
    return HistoriqueMedicament(
      id: id,
      nom: data['nom'] ?? '',
      date: data['date'] ?? '',
      heure: data['heure'] ?? '',
      quantite: data['quantite'] ?? 0,
      pris: data['pris'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'date': date,
      'heure': heure,
      'quantite': quantite,
      'pris': pris,
    };
  }
}
