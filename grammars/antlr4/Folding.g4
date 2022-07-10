grammar Folding;

////// Parser //////

file
    : namespace? importEx* definition*
    ;

//// import
importEx
    : IMPORT package DOT (ID|opIdWrap|aopIdWrap) (AS ID)? (FOREIGN typeEx)?
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
    : UNWRAP? LBRACE compo* RBRACE
    ;
compo
    : definition|value
    ;

//// data
data
    : DATA ID typeParam* defInType+ definingBody
    ;

//// type
typeParam
    : LPAREN ID typeEx* RPAREN
    ;
type
    : TYPE ID typeParam* (TILDE typeEx+)? typeDefBody
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

//// impl
impl
    : IMPL typeParam* typeEx implBody
    ;
implBody: LBRACE def* RBRACE ;

//// define collect
definition
    : def | val | var | type | impl | data
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
opParameter: LPAREN paramEx paramEx RPAREN ;
aopParameter: LPAREN paramEx RPAREN ;

//// argument
argEx: (ID ASSGIN)? value (TILDE typeEx)? ;
argValue
    : LPAREN argEx* RPAREN
    ;

//// definition
val: VAL ID typeEx? ASSGIN value ;
var: VAR ID typeEx? ASSGIN value ;
def
    : FOLDING? ID parameter* typeEx? ASSGIN value
    | FOLDING? opIdWrap opParameter typeEx? ASSGIN value
    | FOLDING? aopIdWrap aopParameter typeEx? ASSGIN value
    | FOLDING? ID FOREIGN parameterInType* typeEx
    | FOLDING? opIdWrap FOREIGN opParameterInType typeEx
    | FOLDING? aopIdWrap FOREIGN aopParameterInType typeEx
    ;

//// id utill
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

//// typeEx
typeEx
    : LPAREN typeEx ARROW typeEx RPAREN
    | typeEx ARROW typeEx
    | typeExSingle
    | WILDCARD
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
DATA: 'data' ;
FOREIGN: 'foreign' ;
FOLDING: 'folding' ;
NAMESPACE: 'namespace' ;
IMPORT: 'import' ;
IMPL: 'impl' ;
RETURN: 'return' ;
TYPE: 'type' ;
VAR: 'var' ;
VAL: 'val' ;
UNWRAP: 'unwrap' ;


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



