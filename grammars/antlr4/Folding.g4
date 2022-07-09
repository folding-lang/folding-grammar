grammar Folding;

////// Parser //////

file
    : namespace? importEx* definition*
    ;

//// import
importEx
    : IMPORT package (AS ID)? (FOREGIN typeEx)?
    ;

//// package
package
    : ID (DOT ID)*
    ;
namespace
    : NAMESPACE package
    ;

//// body
body
    : LBRACE compo* RBRACE
    ;
compo
    : definition|value
    ;

//// type
type
    : TYPE ID (COLON typeEx (COMMA typeEx)*)? definingBody
    ;

//// define collect
definition
    : def | val | var | type
    ;
definingBody
    : LBRACE definition* RBRACE
    ;

//// value
value
    : ID
    | Integer | LPAREN Integer RPAREN
    | Double | LPAREN Double RPAREN
    | String | LPAREN String RPAREN
    | value argValue+ | LPAREN value argValue+ RPAREN
    | value OPID value | LPAREN value OPID value RPAREN
    | OPID value | LPAREN OPID value
    | opIdWrap
    | aopIdWrap
    | body
    ;

//// parameter
paramEx
    : ID COLON typeEx ELLIPSIS? (ASSGIN value)?
    ;
parameter
    : LPAREN ((paramEx COMMA)* paramEx)? RPAREN
    ;

//// argument
argEx: (ID ASSGIN)? value ;
argValue: LPAREN argEx* RPAREN ;

//// definition
val: VAL ID (COLON typeEx)? ASSGIN value ;
var: VAR ID (COLON typeEx)? ASSGIN value ;
def
    : ID parameter* (COLON typeEx)? ASSGIN value
    | opIdWrap parameter{2} (COLON typeEx)? ASSGIN value
    | aopIdWrap parameter (COLON typeEx)? ASSGIN value
    ;

//// id utill
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

//// typeEx
typeEx
    : LPAREN typeEx ARROW typeEx RPAREN
    | typeEx ARROW typeEx
    | typeExSingle
    ;
typeExSingle
    : ID typeExUnit*
    ;
typeExUnit
    : LPAREN typeEx RPAREN
    ;



////// Lexer //////

//// WS

WS  :  [ \t\r\n\u000C]+ -> skip
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
    ;

//// Keywards

AS: 'as' ;
DEF: 'def' ;
FOREGIN: 'foregin' ;
FOLDING: 'folding' ;
NAMESPACE: 'namespace' ;
IMPORT: 'import' ;
RETURN: 'return' ;
TYPE: 'type' ;
VAR: 'var' ;
VAL: 'val' ;


//// Signs

ASSGIN: '=' ;
COLON: ':' ;
ELLIPSIS: '...' ;
DOT: '.' ;
COMMA: ',' ;
LPAREN: '(' ;
RPAREN: ')' ;
LSQUARE: '[' ;
RSQUARE: ']' ;
LBRACE: '{' ;
RBRACE: '}' ;
ARROW: '->' ;
LANGLE: '<' ;
RANGLE: '>' ;
HASH: '#' ;
AT: '@' ;
TILDE: '~' ;

//// ID

fragment IDLETTERHEAD
    :   [_a-zA-Z]  ;

fragment IDLETTERTAIL
    :   [-_a-zA-Z0-9]  ;

fragment IDLETTERSPECIAL
    :   ~[~(){},'"`[\] a-zA-Z0-9\n\r\t]  ;

ID: IDLETTERHEAD IDLETTERTAIL* ;
OPID: IDLETTERSPECIAL+ ;


//// default data struct

// nums
fragment DIGITLETTER
    :   [0-9]  ;

Integer: DIGITLETTER+ ;
Double: DIGITLETTER+ '.' DIGITLETTER+ ;

// string
String
	:	'"' StringCharacters? '"'
	;

fragment StringCharacters
	:	StringCharacter+
	;

fragment StringCharacter
	:	~["\\\r\n]
	|	EscapeSequence
	;

fragment EscapeSequence
	:	'\\' [btnfr"'\\]
	;



