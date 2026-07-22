import '../data/database/database.dart';
import '../data/datasources/local_data_source.dart';
import '../data/repositories/storage_repository.dart';

/// Service locator for dependency injection
/// Provides singleton instances of database, data sources, and repositories
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  AppDatabase? _database;
  LocalDataSource? _localDataSource;
  StorageRepository? _storageRepository;
  bool _isInitialized = false;

  /// Whether the service locator has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all services
  /// Must be called before app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _database = AppDatabase();
      _localDataSource = LocalDataSource(_database!);
      _storageRepository = StorageRepository(_localDataSource!);

      // Seed initial data
      await _localDataSource!.seedInitialData();

      _isInitialized = true;
    } catch (e) {
      // If initialization fails, clean up and rethrow
      await dispose();
      throw StateError('Failed to initialize ServiceLocator: $e');
    }
  }

  /// Get the database instance
  AppDatabase get database {
    if (!_isInitialized || _database == null) {
      throw StateError(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _database!;
  }

  /// Get the local data source
  LocalDataSource get localDataSource {
    if (!_isInitialized || _localDataSource == null) {
      throw StateError(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _localDataSource!;
  }

  /// Get the storage repository
  StorageRepository get storageRepository {
    if (!_isInitialized || _storageRepository == null) {
      throw StateError(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _storageRepository!;
  }

  /// Dispose all resources
  Future<void> dispose() async {
    try {
      await _database?.close();
    } catch (e) {
      // Ignore close errors
    }
    _database = null;
    _localDataSource = null;
    _storageRepository = null;
    _isInitialized = false;
  }
}
