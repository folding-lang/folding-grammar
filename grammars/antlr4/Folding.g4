grammar Folding;

////// Parser //////

file
    : namespace? importEx* (definition|field|annotationDef|newdata)*
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
    : field|value|returning
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
    : annotationBlock? Class ID typeParam? constructor_ classBody
    ;
classBody
    : LBRACE doBlock? subconstructor* staticBlock? (field|def)* RBRACE
    | LBRACE subconstructor* doBlock? staticBlock? (field|def)* RBRACE
    | LBRACE staticBlock? doBlock? subconstructor* (field|def)* RBRACE
    | LBRACE staticBlock? subconstructor* doBlock? (field|def)* RBRACE
    ;
constructor_
    : parameter
    ;
subconstructor
    : constructor_ BIGARROW value
    ;

//// interface
interface_
    : annotationBlock? INTERFACE ID typeParam? (TILDE typeEx+)? interfaceBody
    ;
interfaceBody
    : LBRACE staticBlock? defInInterface* RBRACE
    ;
valInInterface: VAL ID typeEx ;
varInInterface: VAR ID typeEx ;

defInInterface
    : annotationBlock? ID compiledId? typeParam? parameter? BIGARROW COLON typeEx
    | annotationBlock? ID compiledId? typeParam? parameter? BIGARROW (COLON typeEx)? value
    ;

//// newdata
newdata
    : annotationBlock? NEWDATA ID LBRACE literal* RBRACE
    ;

//// type
typeParam
    : typeParamCompo+
    ;
typeParamCompo: ID (TILDE typeEx)* ;


//// define collect
definition
    : def | class_ | interface_
    ;
field
    : annotationBlock? (val_ | var_)
    ;

//// value
value
    : Integer | Double | String | literal
    | (package_ DOT)? ID
    | (package_ DOT)? opIdWrap
    | (package_ DOT)? aopIdWrap
    | value argValue
    | OPID value
    | value OPID value
    | doBlock
    | lambda
    | value COLON ID
    | LPAREN value RPAREN
    | value typeCasting
    ;

typeCasting: AS typeEx ;

//// parameter
paramEx
    : annotationBlock? ID typeEx ELLIPSIS? (ASSGIN value)?
    ;
parameter: COLON paramEx* ;
opParameter: COLON paramEx paramEx ;
aopParameter: COLON paramEx ;

//// argument
argEx
    : (ID ASSGIN)? value
    | ID? LBRACE value* RBRACE
    ;
argValue
    : (TILDE typeEx+)? LPAREN argEx* RPAREN
    ;

//// definition
val_: valSetted|valInInterface ;
var_: varSetted|varInInterface ;
valSetted: VAL ID typeEx? ASSGIN value ;
varSetted: VAR ID typeEx? ASSGIN value ;
def
    : annotationBlock? ID compiledId? typeParam? parameter? BIGARROW (COLON typeEx)? value
    | annotationBlock? opIdWrap compiledId? typeParam? opParameter BIGARROW (COLON typeEx)? value
    | annotationBlock? aopIdWrap compiledId? typeParam? aopParameter BIGARROW (COLON typeEx)? value
    | annotationBlock? ID compiledId? typeParam? parameter? foreign
    | annotationBlock? opIdWrap compiledId? typeParam? opParameter foreign
    | annotationBlock? aopIdWrap compiledId? typeParam? aopParameter foreign
    | annotationBlock? TEMPLATE ID compiledId? typeParam? parameter? (foreign|RawString)
    | annotationBlock? TEMPLATE opIdWrap compiledId? typeParam? opParameter (foreign|RawString)
    | annotationBlock? TEMPLATE aopIdWrap compiledId? typeParam? aopParameter (foreign|RawString)
    ;

//// compiling util
compiledId
    : literal
    ;

//// lambda
lambdaParamEx
    : ID (TILDE typeEx ELLIPSIS?)? (ASSGIN value)?
    ;
lambda
    : LSQUARE (typeParam COLON)? lambdaParamEx* RSQUARE value
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
literal
    : Sharp ID
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
TEMPLATE: 'template' ;
NAMESPACE: 'package' ;
OVERRIDE: 'override' ;
INTERNAL: 'internal' ;
IMPORT: 'import' ;
RETURN: 'return' ;
VAR: 'var' ;
VAL: 'val' ;
STATIC: 'static' ;
INTERFACE: 'interface' ;
NEWDATA: 'newdata' ;


//// Signs

ASSGIN: '=' ;
BIGARROW: '=>' ;
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
DOUBLECOLON: '::' ;
Sharp: '#' ;

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



