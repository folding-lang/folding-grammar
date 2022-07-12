grammar Folding;

////// Parser //////

file
    : namespace? importEx* definition*
    ;

//// import
importEx
    : IMPORT package importBody?
    ;
importBody
    : LBRACE importElement* RBRACE
    ;
importElement
    : (ID|opIdWrap|aopIdWrap) (FOREIGN FOLDING? typeEx)?
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
    : DO? LBRACE compo* RBRACE
    ;
compo
    : definitionInBody|value
    ;
definitionInBody
    : def | var | val | impl | data
    ;

//// data
data
    : DATA ID typeParam? (TILDE typeEx+)? dataBody
    ;
dataBody
    : LBRACE constuctor* (definitionInData|staticDefinition)* RBRACE
    ;
definitionInData
    : INTERNAL? OVERRIDE? (val|var|def|impl)
    ;
staticDefinition
    : STATIC (val|var|def|data)
    ;
constuctor
    : parameter+ (ASSGIN value)?
    ;

//// type
typeParam
    : LSQUARE (ID (TILDE typeEx+)?)+ RSQUARE
    ;
typeParamOnType
    : LPAREN ID+ RPAREN
    ;
type
    : TYPE ID typeParamOnType (TILDE typeEx+)? typeDefBody
    ;
typeDefBody
    : LBRACE defInType* RBRACE
    ;
defInType
    : ID typeParam? parameterInType* typeEx
    | opIdWrap typeParam? opParameterInType typeEx
    | aopIdWrap typeParam? aopParameterInType typeEx
    ;
paramExInType: typeEx ELLIPSIS? ;
parameterInType: LPAREN paramExInType* RPAREN ;
opParameterInType: LPAREN paramExInType paramExInType RPAREN ;
aopParameterInType: LPAREN paramExInType RPAREN ;

//// impl
impl
    : IMPL typeParam* typeEx implBody
    ;
implBody: LBRACE defInImpl* RBRACE ;

paramExInImpl: ID (ASSGIN value)? ;
parameterInImpl: LPAREN paramExInImpl* RPAREN ;
opParameterInImpl: LPAREN paramExInImpl paramExInImpl RPAREN ;
aopParameterInImpl: LPAREN paramExInImpl RPAREN ;

defInImpl
    : FOLDING? ID parameterInImpl* ASSGIN value
    | FOLDING? opIdWrap opParameterInImpl ASSGIN value
    | FOLDING? aopIdWrap aopParameterInImpl ASSGIN value
    | FOLDING? ID FOREIGN
    | FOLDING? opIdWrap FOREIGN
    | FOLDING? aopIdWrap FOREIGN
    ;

//// define collect
definition
    : def | val | var | type | impl | data
    ;

//// value
value
    : ID
    | Integer | LPAREN Integer RPAREN
    | Double | LPAREN Double RPAREN
    | String | LPAREN String RPAREN
    | value argValue | LPAREN value argValue RPAREN
    | value OPID value | LPAREN value OPID value RPAREN
    | OPID value | LPAREN OPID value
    | value DOT value
    | opIdWrap
    | aopIdWrap
    | body
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
    : FOLDING? ID typeParam? parameter* typeEx? ASSGIN value
    | FOLDING? opIdWrap typeParam? opParameter typeEx? ASSGIN value
    | FOLDING? aopIdWrap typeParam aopParameter typeEx? ASSGIN value
    | FOLDING? ID typeParam? FOREIGN parameterInType* typeEx
    | FOLDING? opIdWrap typeParam? FOREIGN opParameterInType typeEx
    | FOLDING? aopIdWrap typeParam? FOREIGN aopParameterInType typeEx
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
    : ID (LPAREN typeEx+ RPAREN)?
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
OVERRIDE: 'override' ;
INTERNAL: 'internal' ;
IMPORT: 'import' ;
IMPL: 'impl' ;
RETURN: 'return' ;
TYPE: 'type' ;
VAR: 'var' ;
VAL: 'val' ;
DO: 'do' ;
STATIC: 'static' ;


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

//// ID

fragment IDLETTERHEAD
    :   [_a-zA-Z]  ;

fragment IDLETTERTAIL
    :   [-_a-zA-Z0-9]  ;

fragment IDLETTERSPECIAL
    :   [-<>#$.~|+=*&%^@!?/\\:;]  ;

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



