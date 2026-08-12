/// A state as exposed by the news APIs (`/api/states`).
///
/// Note: these ids are a different id space from the ones returned by
/// `/api/states-images` (used by the state selection feature), so the two must
/// never be mixed. Matching is done by name.
class NewsState {
  final int id;
  final String name;

  const NewsState({required this.id, required this.name});
}
