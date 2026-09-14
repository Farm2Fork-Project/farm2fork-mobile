/// Wraps [text] in Unicode bidi isolate marks (LRI/PDI) so an
/// inherently left-to-right value -- an order ID, a blockchain hash --
/// keeps its own internal digit/punctuation order when embedded inside
/// a right-to-left (Urdu) sentence, instead of being reordered along
/// with the surrounding text.
String isolateLtr(String text) => '\u2066$text\u2069';
