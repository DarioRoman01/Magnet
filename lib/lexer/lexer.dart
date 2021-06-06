import 'package:Magnet/lexer/token.dart';

class Lexer {
  String source;
  String character;
  int position;
  int read_position;

  Lexer(this.source, this.character, this.position, this.read_position) {
    readCharacter();
  }

  Token nextToken() {
    skipWhitespaces();
    Token token;

    if (RegExp(r'^=$').hasMatch(character)) {
      if (peekCharacter() == '=') {
        token = makeTwoCharacterToken(TokenType.EQ);
      } else if (peekCharacter() == '>') {
        token = makeTwoCharacterToken(TokenType.ARROW);
      } else {
        token = Token(TokenType.ASSING, character);
      }
    } else if (RegExp(r'^\+$').hasMatch(character)) {
      token = Token(TokenType.PLUS, character);

    } else if (RegExp(r'^$').hasMatch(character)) {
      token = Token(TokenType.EOF, character);

    } else if (RegExp(r'^\($').hasMatch(character)) {
      token = Token(TokenType.LPAREN, character);

    } else if (RegExp(r'^\)$').hasMatch(character)) {
      token = Token(TokenType.RPAREN, character);

    } else if (RegExp(r'^\@$').hasMatch(character)) {
      token = Token(TokenType.LET, character);

    } else if (RegExp(r'^\[$').hasMatch(character)) {
      token = Token(TokenType.LBRACKET, character);

    } else if (RegExp(r'^\]$').hasMatch(character)) {
      token = Token(TokenType.RBRACKET, character);

    } else if (RegExp(r'^\{$').hasMatch(character)) {
      token = Token(TokenType.LBRACE, character);

    } else if (RegExp(r'^\}$').hasMatch(character)) {
      token = Token(TokenType.RBRACE, character);

    } else if (RegExp(r'^:$').hasMatch(character)) {
      token = Token(TokenType.COLON, character);
  
    } else if (RegExp(r'^\.$').hasMatch(character)) {
      token = Token(TokenType.DOT, character);

    } else if (RegExp(r'^;$').hasMatch(character)) {
      token = Token(TokenType.SEMICOLON, character);

    } else if (RegExp(r'^%$').hasMatch(character)) {
      token = Token(TokenType.MOD, character);

    } else if (RegExp(r'^-$').hasMatch(character)) {
      token = Token(TokenType.MINUS, character);

    } else if (RegExp(r'^\*$').hasMatch(character)) {
      token = Token(TokenType.TIMES, character);

    } else if (RegExp(r'^/$').hasMatch(character)) {
      token = Token(TokenType.DIVISION, character);

    } else if (RegExp(r'^"$').hasMatch(character)) {
      var literal = readString();
      token = Token(TokenType.STRING, literal);

    } else if (isLetter(character)) {
      var literal = readIdeantifier();
      var type = lookUpTokenType(literal);
      return Token(type, literal);

    } else if (isNumber(character)) {
      var literal = readNumber();
      return Token(TokenType.INT, literal);
      
    } else if (RegExp(r'^>$').hasMatch(character)) {
      if (peekCharacter() == '=') {
        token = makeTwoCharacterToken(TokenType.GTOREQ);
      } else {
        token = Token(TokenType.GT, character);
      }

    } else if  (RegExp(r'^<$').hasMatch(character)) {
      if (peekCharacter() == '=') {
        token = makeTwoCharacterToken(TokenType.LTOREQ);
      } else {
        token = Token(TokenType.LT, character);
      }

    } else if (RegExp(r'^|$').hasMatch(character)) {
      if (peekCharacter() == '|') {
        token = makeTwoCharacterToken(TokenType.OR);
      } else {
        token = Token(TokenType.BAR, character);
      }

    } else if  (RegExp(r'^&$').hasMatch(character)) {
      if (peekCharacter() == '&') {
        token = makeTwoCharacterToken(TokenType.AND);
      } else {
        token = Token(TokenType.ILLEGAL, character);
      }

    } else {
      token = Token(TokenType.ILLEGAL, character);
    }

    readCharacter();
    return token;
  }

  Token makeTwoCharacterToken(TokenType type) {
    var prefix = character;
    readCharacter();
    var suffix = character;
    return Token(type, '$prefix$suffix');
  }

  bool isLetter(String char) {
    var exp = RegExp(r'^[a-záéíóúA-ZÁÉÍÓÚñÑ_]$');
    return exp.hasMatch(character);
  }

  bool isNumber(String char) => RegExp(r'^\d$').hasMatch(character);

  void readCharacter() {
    if (read_position >= source.length) {
      character = '';
    } else {
      character = source[read_position];
    }

    position = read_position;
    read_position += 1;
  }

  String readIdeantifier() {
    var intiPosition = position;
    while (isLetter(character) || isNumber(character)) {
      readCharacter();
    }

    return source.substring(intiPosition, position);
  }

  String readNumber() {
    var initPosition = position;
    while (isNumber(character)) {
      readCharacter();
    }

    return source.substring(initPosition, position);
  }

  String readString() {
    readCharacter();
    var initPosition = position;
    while (character != '"' && read_position <= source.length) {
      readCharacter();
    }

    return source.substring(initPosition, position);
  }

  String peekCharacter() {
    if (read_position >= source.length) {
      return '';
    }

    return source[read_position];
  }

  void skipWhitespaces() {
    var re = RegExp(r'^\s$');
    while (re.hasMatch(character)) {
      readCharacter();
    }
  }
}