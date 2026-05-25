import 'package:flutter/services.dart';

/// Incremental romaji-to-hiragana conversion modeled after jp-verb-quiz.
class RomajiToHiraganaConverter {
  static const Map<String, String> _replace1 = {
    'a': 'あ',
    'i': 'い',
    'u': 'う',
    'e': 'え',
    'o': 'お',
  };

  static const Map<String, String> _replace2 = {
    'ka': 'か', 'ki': 'き', 'ku': 'く', 'ke': 'け', 'ko': 'こ',
    'sa': 'さ', 'si': 'し', 'su': 'す', 'se': 'せ', 'so': 'そ',
    'ta': 'た', 'ti': 'ち', 'tu': 'つ', 'te': 'て', 'to': 'と',
    'na': 'な', 'ni': 'に', 'nu': 'ぬ', 'ne': 'ね', 'no': 'の',
    'ha': 'は', 'hi': 'ひ', 'hu': 'ふ', 'he': 'へ', 'ho': 'ほ',
    'ma': 'ま', 'mi': 'み', 'mu': 'む', 'me': 'め', 'mo': 'も',
    'ra': 'ら', 'ri': 'り', 'ru': 'る', 're': 'れ', 'ro': 'ろ',
    'ga': 'が', 'gi': 'ぎ', 'gu': 'ぐ', 'ge': 'げ', 'go': 'ご',
    'za': 'ざ', 'zi': 'じ', 'zu': 'ず', 'ze': 'ぜ', 'zo': 'ぞ',
    'da': 'だ', 'di': 'ぢ', 'du': 'づ', 'de': 'で', 'do': 'ど',
    'ba': 'ば', 'bi': 'び', 'bu': 'ぶ', 'be': 'べ', 'bo': 'ぼ',
    'pa': 'ぱ', 'pi': 'ぴ', 'pu': 'ぷ', 'pe': 'ぺ', 'po': 'ぽ',
    'qa': 'くぁ', 'qi': 'くぃ', 'qu': 'く', 'qe': 'くぇ', 'qo': 'くぉ',
    'wa': 'わ', 'wi': 'うぃ', 'wu': 'う', 'we': 'うぇ', 'wo': 'を',
    'ya': 'や', 'yi': 'い', 'yu': 'ゆ', 'ye': 'いぇ', 'yo': 'よ',
    'fa': 'ふぁ', 'fi': 'ふぃ', 'fu': 'ふ', 'fe': 'ふぇ', 'fo': 'ふぉ',
    'ja': 'じゃ', 'ji': 'じ', 'ju': 'じゅ', 'je': 'じぇ', 'jo': 'じょ',
    'la': 'ぁ', 'li': 'ぃ', 'lu': 'っ', 'le': 'ぇ', 'lo': 'ぉ',
    'xa': 'ぁ', 'xi': 'ぃ', 'xu': 'ぅ', 'xe': 'ぇ', 'xo': 'ぉ',
    'ca': 'か', 'ci': 'し', 'cu': 'く', 'ce': 'せ', 'co': 'こ',
    'va': 'ゔぁ', 'vi': 'ゔぃ', 'vu': 'ゔ', 've': 'ゔぇ', 'vo': 'ゔぉ',
    'nn': 'ん', "n'": 'ん',
    'nb': 'んb', 'nc': 'んc', 'nd': 'んd', 'nf': 'んf', 'ng': 'んg',
    'nh': 'んh', 'nj': 'んj', 'nk': 'んk', 'nl': 'んl', 'nm': 'んm',
    'np': 'んp', 'nq': 'んq', 'nr': 'んr', 'ns': 'んs', 'nt': 'んt',
    'nv': 'んv', 'nw': 'んw', 'nx': 'んx', 'nz': 'んz',
    'aa': 'っa', 'bb': 'っb', 'cc': 'っc', 'dd': 'っd', 'ee': 'っe',
    'ff': 'っf', 'gg': 'っg', 'hh': 'っh', 'ii': 'っi', 'jj': 'っj',
    'kk': 'っk', 'll': 'っl', 'mm': 'っm', 'oo': 'っo', 'pp': 'っp',
    'qq': 'っq', 'rr': 'っr', 'ss': 'っs', 'tt': 'っt', 'uu': 'っu',
    'vv': 'っv', 'ww': 'っw', 'xx': 'っx', 'yy': 'っy', 'zz': 'っz',
  };

  static const Map<String, String> _replace3 = {
    'kya': 'きゃ', 'kyi': 'きぃ', 'kyu': 'きゅ', 'kye': 'きぇ', 'kyo': 'きょ',
    'sha': 'しゃ', 'shi': 'し', 'shu': 'しゅ', 'she': 'しぇ', 'sho': 'しょ',
    'cha': 'ちゃ', 'chi': 'ち', 'chu': 'ちゅ', 'che': 'ちぇ', 'cho': 'ちょ',
    'nya': 'にゃ', 'nyi': 'にぃ', 'nyu': 'にゅ', 'nye': 'にぇ', 'nyo': 'にょ',
    'hya': 'ひゃ', 'hyi': 'ひぃ', 'hyu': 'ひゅ', 'hye': 'ひぇ', 'hyo': 'ひょ',
    'mya': 'みゃ', 'myi': 'みぃ', 'myu': 'みゅ', 'mye': 'みぇ', 'myo': 'みょ',
    'rya': 'りゃ', 'ryi': 'りぃ', 'ryu': 'りゅ', 'rye': 'りぇ', 'ryo': 'りょ',
    'gya': 'ぎゃ', 'gyi': 'ぎぃ', 'gyu': 'ぎゅ', 'gye': 'ぎぇ', 'gyo': 'ぎょ',
    'zya': 'じゃ', 'zyi': 'じぃ', 'zyu': 'じゅ', 'zye': 'じぇ', 'zyo': 'じょ',
    'dya': 'ぢゃ', 'dyi': 'ぢぃ', 'dyu': 'ぢゅ', 'dye': 'ぢぇ', 'dyo': 'ぢょ',
    'bya': 'びゃ', 'byi': 'びぃ', 'byu': 'びゅ', 'bye': 'びぇ', 'byo': 'びょ',
    'pya': 'ぴゃ', 'pyi': 'ぴぃ', 'pyu': 'ぴゅ', 'pye': 'ぴぇ', 'pyo': 'ぴょ',
    'jiu': 'じゅう', 'jyu': 'じゅ', 'jyo': 'じょ',
    'tsu': 'つ',
  };

  static TextEditingValue convert(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      return value;
    }
    final pos = selection.baseOffset;
    if (pos <= 0 || pos > value.text.length) {
      return value;
    }
    final text = value.text;
    final lower = text.toLowerCase();
    final last3 = pos >= 3 ? lower.substring(pos - 3, pos) : '';
    final last2 = pos >= 2 ? lower.substring(pos - 2, pos) : '';
    final last1 = lower.substring(pos - 1, pos);

    String? replacement;
    var removeCount = 0;
    if (_replace3.containsKey(last3)) {
      replacement = _replace3[last3];
      removeCount = 3;
    } else if (_replace2.containsKey(last2)) {
      replacement = _replace2[last2];
      removeCount = 2;
    } else if (_replace1.containsKey(last1)) {
      replacement = _replace1[last1];
      removeCount = 1;
    }
    if (replacement == null) {
      return value;
    }

    final start = pos - removeCount;
    final nextText = text.replaceRange(start, pos, replacement);
    final nextOffset = start + replacement.length;
    return TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextOffset),
      composing: TextRange.empty,
    );
  }
}
