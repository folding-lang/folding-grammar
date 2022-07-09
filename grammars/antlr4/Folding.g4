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
typeParam
    : LPAREN ID ( typeEx+)? RPAREN
    ;
type
    : TYPE ID typeParam* TILDE ( typeEx+)? typeDefBody
    ;
typeDefBody
    : LBRACE defInType* RBRACE
    ;
defInType
    : ID parameterInType* typeEx
    | opIdWrap opParameterInType typeEx
    | aopIdWrap aopParameterInType typeEx
    ;
paramExInType: typeEx ELLIPSIS? ;
parameterInType: LPAREN paramExInType* RPAREN ;
opParameterInType: LPAREN paramExInType paramExInType RPAREN ;
aopParameterInType: LPAREN paramExInType RPAREN ;

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
    | WILDCARD
    ;

//// parameter
paramEx
    : ID  typeEx ELLIPSIS? (ASSGIN value)?
    ;
parameter: LPAREN paramEx* RPAREN ;
opParameter: LPAREN paramEx{2} RPAREN ;
aopParameter: LPAREN paramEx RPAREN ;

//// argument
argEx: (ID ASSGIN)? value ;
argValue
    : LPAREN argEx* RPAREN
    ;

//// definition
val: VAL ID typeEx? ASSGIN value ;
var: VAR ID typeEx? ASSGIN value ;
def
    : ID parameter* typeEx? ASSGIN value
    | opIdWrap opParameter typeEx? ASSGIN value
    | aopIdWrap aopParameter typeEx? ASSGIN value
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
ELLIPSIS: '...' ;
DOT: '.' ;
LPAREN: '(' ;
RPAREN: ')' ;
LSQUARE: '[' ;
RSQUARE: ']' ;
LBRACE: '{' ;
RBRACE: '}' ;
ARROW: '->' ;
TILDE: '~' ;
WILDCARD: '_' ;

//// ID

fragment IDLETTERHEAD
    :   [_a-zA-Z]  ;

fragment IDLETTERTAIL
    :   [-_a-zA-Z0-9]  ;

fragment IDLETTERSPECIAL
    :   [-<>#$.~|+=*&%^@!?/\\]  ;

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



