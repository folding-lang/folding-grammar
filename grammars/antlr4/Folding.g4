grammar Folding;

////// Parser //////

file
    : namespace? importEx* (definition|field|annotationDef|newset)*
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
    : LBRACE (constructor_*|constructorSelf) field* defInInterface* impl* RBRACE
    ;
constructor_
    : ID parameter? doBlock?
    ;
constructorSelf
    : parameter? doBlock?
    ;

defInInterface
    : annotationBlock? ID compiledId? typeParam? parameter? typeEx value?
    ;

//// impl
impl
    : IMPL typeParam? typeEx implBody?
    ;
implBody
    : LBRACE defInImpl* RBRACE
    ;
defInImpl
    : annotationBlock? ID compiledId? typeParam? parameter? typeEx ASSGIN value
    ;

//// newdata
newset
    : annotationBlock? NEWSET ID LBRACE Literal* RBRACE
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
value
    : Integer | Double | String | Literal
    | (package_ DOT)? ID
    | (package_ DOT)? opIdWrap
    | (package_ DOT)? aopIdWrap
    | value COLON ID
    | value argValue
    | value typeCasting
    | OPID value
    | value OPID value
    | doBlock
    | lambda
    | LPAREN value RPAREN
    ;

typeCasting: TILDE typeEx ;

//// parameter
paramEx
    : annotationBlock? value TILDE typeEx
    | annotationBlock? value
    ;
parameter: LPAREN paramEx+ RPAREN ;

//// argument
argEx
    : (ID ASSGIN)? value
    | ID? LBRACE value* RBRACE
    ;
argValue
    : (TILDE typeEx+)? LPAREN argEx* RPAREN
    ;

//// definition
field: fieldSetted|fieldNotInit ;
fieldNotInit: FIELD MUTABLE? ID typeEx ;
fieldSetted: FIELD MUTABLE? ID typeEx? ASSGIN value ;
def
    : justDef
    | template
    | foreignDef
    ;
justDef
    : annotationBlock? (ID|opIdWrap|aopIdWrap) compiledId? typeParam? parameter? typeEx ASSGIN value
    ;
template
    : annotationBlock? TEMPLATE (ID|opIdWrap|aopIdWrap) compiledId? typeParam? parameter? (FOREIGN typeEx foreignBody?|ASSGIN typeEx RawString)
    ;
foreignDef
    : annotationBlock? (ID|opIdWrap|aopIdWrap) compiledId? typeParam? parameter? FOREIGN typeEx foreignBody?
    ;

//// compiling util
compiledId
    : Literal
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

ABSTRACT: 'abstract' ;
ANNOTATION: 'annotation' ;
CLASS: 'class' ;
DO: 'do' ;
FOREIGN: 'foreign' ;
TEMPLATE: 'template' ;
NAMESPACE: 'package' ;
INTERNAL: 'internal' ;
IMPORT: 'import' ;
IMPL: 'impl' ;
RETURN: 'return' ;
MUTABLE: 'mutable' ;
FIELD: 'field' ;
STATIC: 'static' ;
NEWSET: 'newset' ;


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
COLON: ':' ;

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



