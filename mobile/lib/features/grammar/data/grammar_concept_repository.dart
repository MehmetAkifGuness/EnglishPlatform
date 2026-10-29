import 'grammar_concept.dart';
import 'grammar_concept_api.dart';

class GrammarConceptRepository {
  const GrammarConceptRepository(this._api);

  final GrammarConceptApi _api;

  Future<List<GrammarConcept>> fetchConcepts() => _api.fetchConcepts();
}
