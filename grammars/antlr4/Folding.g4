grammar Folding;

////// Parser //////

file
    : namespace? importEx* (definition|field|annotationDef)*
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
doBlock
    : DO LBRACE compo* RBRACE
    ;
compo
    : def|value|returning
    ;
returning
    : RETURN value
    ;

//// static
staticBlock
    : STATIC LBRACE (definition|field)* RBRACE
    ;

//// class
class_
    : annotationBlock? ABSTRACT? Class ID typeParam? (TILDE typeEx+)? classBody
    ;
classBody
    : LBRACE constuctor* staticBlock (definitionInClass|abstractDefinitionInClass)* RBRACE
    ;
definitionInClass
    : INTERNAL? OVERRIDE? (def)
    ;
abstractDefinitionInClass
    : INTERNAL? (fieldInInterface|defInInterface)
    ;
constuctor
    : parameter+ (ASSGIN value)?
    ;

//// interface
interface_
    : annotationBlock? INTERFACE ID typeParam? (TILDE typeEx+)? interfaceBody
    ;
interfaceBody
    : LBRACE staticBlock? (defInInterface|fieldInInterface)* RBRACE
    ;
fieldInInterface
    : annotationBlock? (valInInterface | varInInterface)
    ;
valInInterface: VAL ID typeEx ;
varInInterface: VAR ID typeEx ;

defInInterface
    : annotationBlock? ID typeParam? parameter* typeEx
    | annotationBlock? opIdWrap typeParam? opParameter typeEx
    | annotationBlock? aopIdWrap typeParam? aopParameter typeEx
    | annotationBlock? ID typeParam? parameter* typeEx? ASSGIN value
    | annotationBlock? opIdWrap typeParam? opParameter typeEx? ASSGIN value
    | annotationBlock? aopIdWrap typeParam? aopParameter typeEx? ASSGIN value
    ;

//// type
typeParam
    : LSQUARE typeParamCompo+ RSQUARE
    ;
typeParamCompo: ID (TILDE typeEx)* ;


//// define collect
definition
    : def | class_ | interface_
    ;
field
    : val_ | var_
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
    | doBlock typeCasting?
    | lambda typeCasting?
    | value COLON value typeCasting?
    ;

typeCasting: AS typeEx ;

//// parameter
paramEx
    : annotationBlock? ID typeEx ELLIPSIS? (ASSGIN value)?
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
    : annotationBlock? ID typeParam? parameter* typeEx? ASSGIN value
    | annotationBlock? opIdWrap typeParam? opParameter typeEx? ASSGIN value
    | annotationBlock? aopIdWrap typeParam? aopParameter typeEx? ASSGIN value
    | annotationBlock? ID typeParam? parameter* foreign
    | annotationBlock? opIdWrap typeParam? opParameter foreign
    | annotationBlock? aopIdWrap typeParam? aopParameter foreign
    ;

//// lambda
lambdaParamEx
    : ID (TILDE typeEx ELLIPSIS?)? (ASSGIN value)?
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

//// annotation
annoValue
    : Integer | Double | String
    ;
annoTypeEx
    : 'Int' | 'Double' | 'String'
    ;
annoParam
    : ID annoTypeEx
    ;
annotationDef
    : ID (LPAREN annoParam* RPAREN)?
    ;
annotation
    : ID annoValue*
    | ID LPAREN annoValue* RPAREN
    ;
annotationBlock
    : LSQUARE COLON annotation* COLON RSQUARE
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
ABSTRACT: 'abstract' ;
ANNOTATION: 'annotation' ;
Class: 'class' ;
DO: 'do' ;
EXTERNAL: 'external' ;
FOREIGN: 'foreign' ;
NAMESPACE: 'package' ;
OVERRIDE: 'override' ;
INTERNAL: 'internal' ;
IMPORT: 'import' ;
RETURN: 'return' ;
VAR: 'var' ;
VAL: 'val' ;
STATIC: 'static' ;
INTERFACE: 'interface' ;


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



