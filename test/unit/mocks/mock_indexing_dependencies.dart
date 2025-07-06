import 'package:mockito/mockito.dart';
import 'package:otzaria/indexing/repository/indexing_repository.dart';
import 'package:otzaria/data/data_providers/tantivy_data_provider.dart';

class MockIndexingRepository extends Mock implements IndexingRepository {}

class MockTantivyDataProvider extends Mock implements TantivyDataProvider {}
