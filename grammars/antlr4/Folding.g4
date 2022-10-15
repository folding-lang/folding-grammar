grammar Folding;

////// Parser //////

file
    : namespace? importEx* definition*
    ;

//// import
importEx
    : importVanila
    ;
importVanila: IMPORT package_ importBody? ;
importBody
    : LBRACE importElement* RBRACE
    ;
importElement
    : (package_ DOT)? (ID|opIdWrap|aopIdWrap)
    ;

//// package
package_
    : ID (DOT ID)*
    ;
namespace
    : NAMESPACE package_
    ;

//// body
body
    : IMMEDIATELY? DO LBRACE compo* RBRACE
    ;
compo
    : definitionInBody|value|returning
    ;
definitionInBody
    : def | var_ | val_ | impl | class_ | interface_
    ;
returning
    : RETURN value
    ;

//// data
class_
    : ABSTRACT? DATA ID typeParam? (TILDE typeEx+)? classBody
    ;
classBody
    : LBRACE constuctor* (definitionInClass|staticDefinition|abstractDefinitionInClass)* RBRACE
    ;
definitionInClass
    : INTERNAL? OVERRIDE? (val_|var_|def|impl)
    ;
abstractDefinitionInClass
    : INTERNAL? (propertyInInterface|defInInterface)
    ;
staticDefinition
    : STATIC (val_|var_|def|class_|interface_)
    ;
constuctor
    : parameter+ (ASSGIN value)?
    ;

//// interface
interface_
    : INTERFACE ID typeParam? (TILDE typeEx+)? interfaceBody
    ;
interfaceBody
    : LBRACE (defInInterface|propertyInInterface|staticDefinition)* RBRACE
    ;
propertyInInterface
    : valInInterface | varInInterface
    ;
valInInterface: VAL ID typeEx ;
varInInterface: VAR ID typeEx ;

defInInterface
    : ID typeParam? parameter* typeEx
    | opIdWrap typeParam? opParameter typeEx
    | aopIdWrap typeParam? aopParameter typeEx
    | ID typeParam? parameter* typeEx? ASSGIN value
    | opIdWrap typeParam? opParameter typeEx? ASSGIN value
    | aopIdWrap typeParam? aopParameter typeEx? ASSGIN value
    ;

//// type
typeParam
    : LSQUARE typeParamCompo+ RSQUARE
    ;
typeParamCompo: ID (TILDE typeEx)* ;
typeParamOnTypeclass
    : LPAREN ID+ RPAREN
    ;
typeclass
    : TYPECLASS ID typeParamOnTypeclass (TILDE typeEx+)? typeclassDefBody
    ;
typeclassDefBody
    : LBRACE defInTypeclass* RBRACE
    ;
defInTypeclass
    : ID typeParam? parameter* typeEx
    | opIdWrap typeParam? opParameter typeEx
    | aopIdWrap typeParam? aopParameter typeEx
    ;

//// impl
impl
    : IMPL typeParam* typeEx implBody
    ;
implBody: LBRACE def* RBRACE ;


//// define collect
definition
    : def | val_ | var_ | typeclass | impl | class_ | interface_
    ;

//// value
value
    : (package_ DOT)? ID typeCasting?
    | Integer | LPAREN Integer RPAREN typeCasting?
    | Double | LPAREN Double RPAREN typeCasting?
    | String | LPAREN String RPAREN typeCasting?
    | value argValue typeCasting?
    | LPAREN value argValue RPAREN typeCasting?
    | value OPID value typeCasting?
    | LPAREN value OPID value RPAREN typeCasting?
    | OPID value typeCasting?
    | LPAREN OPID value RPAREN typeCasting?
    | value DOT value typeCasting?
    | (package_ DOT)? opIdWrap typeCasting?
    | (package_ DOT)? aopIdWrap typeCasting?
    | body typeCasting?
    | lambda typeCasting?
    | value COLON value typeCasting?
    ;

typeCasting: AS typeEx ;

//// parameter
paramEx
    : ID  typeEx ELLIPSIS? (ASSGIN value)?
    ;
parameter: LPAREN paramEx* RPAREN ;
opParameter: LPAREN paramEx paramEx RPAREN ;
aopParameter: LPAREN paramEx RPAREN ;

//// argument
argEx
    : (ID ASSGIN)? value
    | ID? LBRACE value* RBRACE
    ;
argValue
    : LPAREN argEx* RPAREN
    ;

//// definition
val_: VAL ID typeEx? ASSGIN value ;
var_: VAR ID typeEx? ASSGIN value ;
def
    : ID typeParam? parameter* typeEx? ASSGIN value
    | opIdWrap typeParam? opParameter typeEx? ASSGIN value
    | aopIdWrap typeParam? aopParameter typeEx? ASSGIN value
    | ID typeParam? parameter* foreign
    | opIdWrap typeParam? opParameter foreign
    | aopIdWrap typeParam? aopParameter foreign
    ;

//// lambda
lambdaParamEx
    : ID  (TILDE typeEx ELLIPSIS?)? (ASSGIN value)?
    ;
lambda
    : LSQUARE lambdaParamEx* RSQUARE value
    ;

//// id utill
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

//// typeEx
typeEx
    : LPAREN typeEx ARROW typeEx RPAREN
    | typeEx ARROW typeEx
    | LPAREN typeExSingle ARROW typeEx RPAREN
    | typeExSingle ARROW typeEx
    | typeExSingle
    ;
typeExSingle
    : (package_ DOT)? ID (LPAREN typeEx+ RPAREN)?
    ;

//// foreign
foreign
    : FOREIGN typeEx foreignBody
    | EXTERNAL typeEx
    ;
foreignBody: LBRACE foreignElement* RBRACE ;
foreignElement
    : foreignPlatform RawString
    | foreignPlatform TILDE String
    ;
foreignPlatform: ID ;


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
ABSTRACT: 'abstract' ;
DATA: 'data' ;
DO: 'do' ;
EXTERNAL: 'external' ;
FOREIGN: 'foreign' ;
NAMESPACE: 'package' ;
OVERRIDE: 'override' ;
INTERNAL: 'internal' ;
IMPORT: 'import' ;
IMPL: 'impl' ;
RETURN: 'return' ;
TYPECLASS: 'class' ;
VAR: 'var' ;
VAL: 'val' ;
STATIC: 'static' ;
INTERFACE: 'interface' ;
IMMEDIATELY: 'immediately' ;


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
COLON: ':' ;

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
    :   '"' StringCharacters? '"'
    ;

RawString
    :   '`' RawStringCharacters '`'
    ;

fragment StringCharacters
    :   StringCharacter+
    ;

fragment RawStringCharacters
    :   RawStringCharacter+
    ;

fragment RawStringCharacter
    :   .
    ;

fragment StringCharacter
    :   ~["\\\r\n]
    |   EscapeSequence
    ;

fragment EscapeSequence
    :   '\\' [btnfr"'\\]
    ;



