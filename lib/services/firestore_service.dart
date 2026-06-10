import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weather_model.dart';

class FirestoreService {
  final String _collectionPath = 'favorites';

  /// Helper getter to check if Firebase has been initialized
  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  /// Adds a weather model (favorite city) to Firestore.
  Future<void> addFavorite(WeatherModel weather) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase başlatılmadı. Lütfen uygulamayı bir Android emülatörde çalıştırın veya Firebase Web ayarlarını yapın.');
    }
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(weather.cityName.toLowerCase().trim());
      await docRef.set(weather.toFirestore());
    } catch (e) {
      throw Exception('Favorilere eklenirken bir hata oluştu: $e');
    }
  }

  /// Removes a favorite city from Firestore by its city name.
  Future<void> deleteFavorite(String cityName) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase başlatılmadı. Lütfen uygulamayı bir Android emülatörde çalıştırın veya Firebase Web ayarlarını yapın.');
    }
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(cityName.toLowerCase().trim());
      await docRef.delete();
    } catch (e) {
      throw Exception('Favorilerden silinirken bir hata oluştu: $e');
    }
  }

  /// Checks if a city is already saved in the favorites list.
  Future<bool> isFavorite(String cityName) async {
    if (!_isFirebaseInitialized) return false;
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(cityName.toLowerCase().trim())
          .get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Returns a stream of the list of favorite cities.
  Stream<List<WeatherModel>> getFavoritesStream() {
    if (!_isFirebaseInitialized) {
      // If Firebase is not initialized, return an empty list stream to prevent UI crash
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection(_collectionPath)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WeatherModel.fromFirestore(doc.data());
      }).toList();
    });
  }
}
