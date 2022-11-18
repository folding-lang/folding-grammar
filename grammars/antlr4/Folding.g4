grammar Folding;

////// Parser //////

file
    : namespace? importEx* (definition|field|annotationDef)*
    ;

//// import
importEx
    : importVanila
    ;
importVanila: IMPORT package_ ;

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
    : fieldAssign|value|returning
    ;
returning
    : RETURN value
    ;
fieldAssign
    : value ASSGIN value
    ;

//// class
class_
    : annotationBlock? CLASS ID typeParam? classBody
    ;
classBody
    : LBRACE (constructor_*|constructorSelf) field* defInInterface* inherit? impl* RBRACE
    ;
constructor_
    : ID parameter? doBlock?
    ;
constructorSelf
    : parameter? doBlock?
    ;

defInInterface
    : annotationBlock? ID typeParam? parameter? typeEx value?
    ;

//// impl
inherit
    : INHERIT typeParam? typeEx implBody?
    ;
impl
    : IMPL typeParam? typeEx implBody?
    ;
implBody
    : LBRACE defInImpl* RBRACE
    ;
defInImpl
    : annotationBlock? ID typeParam? parameter? typeEx ASSGIN value
    ;

//// type
typeParam
    : typeParamCompo+
    ;
typeParamCompo: ID (TILDE typeEx)* ;


//// define collect
definition
    : def | class_
    ;

//// value
defaultValue: Integer | Double | String | Literal ;
value
    : defaultValue #justDefaultValue
    | DOUBLECOLON reference #reflected
    | LPAREN ID+ FROM value RPAREN #callInvFunc
    | reference argValue? #callFuncthon
    | value COLON ID argValue? #callMethod
    | value DOUBLECOLON ID #reflectedMethod
    | value SHARP ID #getField
    | value typeCasting #valueTypeCasting
    | OPID value #callAopFunc
    | value OPID value #callOpFunc
    | doBlock #doExpresion
    | lambda #justLambda
    | LPAREN value RPAREN #parenedValue
    ;
reference
    : (package_ DOT)? ID #justRef
    | (package_ DOT)? opIdWrap #opFuncRef
    | (package_ DOT)? aopIdWrap #aopFuncRef
    ;

typeCasting: As typeEx ;

//// parameter
paramEx
    : ID ELLIPSIS? TILDE typeEx
    ;
paramCEx
    : value TILDE typeEx
    ;
parameter
    : LPAREN paramEx* RPAREN (TILDE LPAREN paramCEx+ RPAREN)?
    ;

//// argument
argEx
    : (ID ASSGIN)? value
    | ID? LBRACE value* RBRACE
    ;
argValue
    : LPAREN (typeEx+ TILDE)?  argEx* RPAREN
    ;

//// definition
field: fieldSetted|fieldNotInit ;
fieldNotInit: FIELD MUTABLE? ID typeEx ;
fieldSetted: FIELD MUTABLE? ID typeEx? ASSGIN value ;
def
    : justDef inverseDefining?
    | foreignDef
    ;
justDef
    : annotationBlock? (ID|opIdWrap|aopIdWrap) typeParam? parameter? typeEx ASSGIN value
    ;
foreignDef
    : annotationBlock? (ID|opIdWrap|aopIdWrap) typeParam? parameter? FOREIGN typeEx foreignBody?
    ;
inverseDefining
    : INVERSE LPAREN inverseDefCompo+ RPAREN
    ;
inverseDefCompo
    : typeEx value #outputParam
    | As ID #necessaryParam
    ;

//// lambda
lambda
    : LSQUARE paramEx* RSQUARE value
    ;

//// id utill
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

//// typeEx
typeEx
    : typeExParameter
    | typeExSingle
    ;
typeExSingle
    : (package_ DOT)? ID (LPAREN typeEx+ RPAREN)?
    ;
typeExParamEx
    : typeEx ELLIPSIS?
    ;
typeExParameter
    : LPAREN typeExParamEx* RPAREN ARROW typeEx
    ;

//// foreign
foreignBody: LBRACE foreignElement* RBRACE | RawString ;
foreignElement
    : foreignPlatform RawString
    | foreignPlatform TILDE String
    ;
foreignPlatform: ID ;

//// annotation
annoValue
    : Integer | Double | String
    ;
annoParam
    : ID typeEx
    ;
annotationDef
    : ANNOTATION ID (LPAREN annoParam* RPAREN)?
    ;
annotation
    : ID annoValue*
    | ID LPAREN annoValue* RPAREN
    ;
annotationBlock
    : LCOLONSQUARE annotation* RCOLONSQUARE
    ;

//// literal
Literal
    : '#' IDLETTERHEAD IDLETTERTAIL*
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

ANNOTATION: 'annotation' ;
CLASS: 'class' ;
DO: 'do' ;
FOREIGN: 'foreign' ;
NAMESPACE: 'package' ;
INTERNAL: 'internal' ;
IMPORT: 'import' ;
IMPL: 'impl' ;
INHERIT: 'inherit' ;
RETURN: 'return' ;
MUTABLE: 'mutable' ;
FIELD: 'field' ;
INVERSE: 'inverse' ;
FROM: 'from' ;


//// Signs

ASSGIN: '=' ;
ELLIPSIS: '...' ;
DOT: '.' ;
LPAREN: '(' ;
RPAREN: ')' ;
LSQUARE: '[' ;
LCOLONSQUARE: '[:' ;
RSQUARE: ']' ;
RCOLONSQUARE: ':]' ;
LBRACE: '{' ;
RBRACE: '}' ;
ARROW: '->' ;
TILDE: '~' ;
As: '~>' ;
COLON: ':' ;
DOUBLECOLON: '::' ;
SHARP: '#' ;

//// ID

fragment IDLETTERHEAD
    :   [_a-zA-Z]  ;

fragment IDLETTERTAIL
    :   [-_a-zA-Z0-9]  ;

fragment IDLETTERSPECIAL
    :   [-<>#$.~|+=*&%^@!?/\\;,]  ;

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



