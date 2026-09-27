import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/smart_contracts/services/wizard_csv.dart';

const _header = 'Name,Description,Primary Asset URL,Creator Name,Royalty Amount,Royalty Address,Additional Asset URLs,Quantity,Edition';
const _row1 = 'csv-1,First,https://example.com/a.png,QA,5%,xAddr,,1,First';
const _row2 = 'csv-2,Second,https://example.com/b.png,QA,,,,2,Second';

void main() {
  group('parseWizardCsv', () {
    for (final entry in {'LF': '\n', 'CRLF': '\r\n', 'CR': '\r'}.entries) {
      test('splits ${entry.key} line endings into rows', () {
        final eol = entry.value;
        final rows = parseWizardCsv('$_header$eol$_row1$eol$_row2$eol');

        expect(rows, hasLength(3));
        expect(rows[0].first, 'Name');
        expect(rows[1].first, 'csv-1');
        expect(rows[2].first, 'csv-2');
        expect(rows[2][7], 2);
      });
    }

    test('handles mixed line endings and drops blank lines', () {
      final rows = parseWizardCsv('$_header\r\n$_row1\n\n$_row2\r\n\r\n');

      expect(rows.map((r) => r.first), ['Name', 'csv-1', 'csv-2']);
    });

    test('keeps quoted commas in a field', () {
      final rows = parseWizardCsv('$_header\ncsv-1,First,https://example.com/a.png,QA,,,"https://x/1.png, https://x/2.png",1,First\n');

      expect(rows[1][6], 'https://x/1.png, https://x/2.png');
    });

    test('a header-only file yields just the header', () {
      expect(parseWizardCsv('$_header\n'), hasLength(1));
    });

    test('an empty file yields no rows', () {
      expect(parseWizardCsv(''), isEmpty);
      expect(parseWizardCsv('\r\n\n'), isEmpty);
    });
  });
}
