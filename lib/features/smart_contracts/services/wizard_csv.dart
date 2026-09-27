import 'package:csv/csv.dart';

/// Parses an NFT collection wizard CSV into rows (header first).
///
/// Accepts LF, CRLF and CR line endings: `CsvToListConverter` only splits on
/// its `eol` (CRLF by default), so an LF-only file would parse as one row.
/// Blank lines are dropped.
List<List<dynamic>> parseWizardCsv(String content) {
  final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  return rows.where((row) => row.any((field) => field.toString().trim().isNotEmpty)).toList();
}
