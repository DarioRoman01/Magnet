enum TokenType {
  AND,
  ARROW,
  ASSING,
  BAR,
  COMMA,
  COLON,
  DATASTRCUT,
  DIVISION,
  DOT,
  ELSE,
  EOF,
  EQ,
  FALSE,
  FOR,
  FUNCTION,
  GT,
  GTOREQ,
  IDENT,
  IF,
  ILLEGAL,
  INT,
  LBRACE,
  LBRACKET,
  LET,
  LPAREN,
  LT,
  LTOREQ,
  MINUS,
  NOT,
  NOT_EQ,
  MOD,
  OR,
  PLUS,
  RBRACE,
  RBRACKET,
  RETURN,
  RPAREN,
  SEMICOLON,
  TIMES, // *
  STRING,
  TRUE,
  TYPENAME,
  WHILE,
}

class Token {
  String literal;
  TokenType tokenType;

  Token(this.tokenType, this.literal);

  String printToken() {
    return 'Token type: $tokenType, literal: $literal';
  }
}

TokenType lookUpTokenType(String literal) {
  var keywords = {
    'false': TokenType.FALSE,
    'f': TokenType.FUNCTION,
    'return': TokenType.RETURN,
    'if': TokenType.IF,
    'else': TokenType.ELSE,
    'true': TokenType.TRUE,
    'while': TokenType.WHILE,
    'for': TokenType.FOR,
    'int': TokenType.TYPENAME,
    'bool': TokenType.TYPENAME,
    'str': TokenType.TYPENAME,
    'float': TokenType.TYPENAME,
  };

  var type = keywords[literal];
  return type ?? TokenType.IDENT;
}
