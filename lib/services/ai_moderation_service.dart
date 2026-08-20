class AiModerationService {

  static final List<String>
      bannedWords = [

    'idiota',

    'estupido',

    'mierda',

    'spam',

    'http',

    'www',

    '.com',

    'hola',
  ];

  static bool isSpam(String text) {

    final lower =
        text.toLowerCase();

    // PALABRAS PROHIBIDAS

    for (String word
        in bannedWords) {

      if (lower.contains(word)) {

        return true;
      }
    }

    // MUCHAS MAYÚSCULAS

    final upperCount =

        text
            .split('')
            .where(
              (c) =>
                  c ==
                  c.toUpperCase(),
            )
            .length;

    if (upperCount > 20) {

      return true;
    }

    // TEXTO MUY CORTO

    if (text.length < 5) {

      return true;
    }

    // MUCHOS SÍMBOLOS

    final symbols = RegExp(
      r'[!@#\$%^&*(),.?":{}|<>]',
    );

    final symbolCount =

        symbols
            .allMatches(text)
            .length;

    if (symbolCount > 15) {

      return true;
    }

    return false;
  }
}