import 'package:bunkai/services/japanese_dictionary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await JapaneseDictionaryService.instance.load();
  });

  test('lookupSurface returns entries for known surface', () {
    final e = JapaneseDictionaryService.instance.lookupSurface('食べる');
    expect(e, isNotEmpty);
    expect(e.first.surface, '食べる');
  });

  test('lookupSurface returns empty for unknown', () {
    expect(JapaneseDictionaryService.instance.lookupSurface('貘'), isEmpty);
  });

  test('containsSurface', () {
    expect(JapaneseDictionaryService.instance.containsSurface('する'), isTrue);
    expect(JapaneseDictionaryService.instance.containsSurface('zzz'), isFalse);
  });

  test('lookupMany includes keys', () {
    final m = JapaneseDictionaryService.instance.lookupMany(['を', 'unknown']);
    expect(m['を'], isNotEmpty);
    expect(m['unknown'], isEmpty);
  });
}
