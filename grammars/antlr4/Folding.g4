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
    : value|returning
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
    : LBRACE constuctor* staticBlock? (definitionInClass|abstractDefinitionInClass)* RBRACE
    ;
definitionInClass
    : annotationBlock? INTERNAL? OVERRIDE? ID compiledId? typeParam? parameter? typeEx? ASSGIN value
    | annotationBlock? INTERNAL? OVERRIDE? ID compiledId? typeParam? parameter? foreign
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
    : annotationBlock? ID compiledId? typeParam? parameter? typeEx
    | annotationBlock? ID compiledId? typeParam? parameter? typeEx? ASSGIN value
    ;

//// newdata
newdata
    : annotationBlock? NEWDATA ID LBRACE literal* RBRACE
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
    : Integer | Double | String | literal
    | (package_ DOT)? ID
    | (package_ DOT)? opIdWrap
    | (package_ DOT)? aopIdWrap
    | value argValue
    | value OPID value
    | OPID value
    | doBlock
    | lambda
    | value COLON value
    | value DOUBLECOLON value
    | LPAREN value RPAREN
    | value typeCasting
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
    : annotationBlock? ID compiledId? typeParam? parameter? typeEx? ASSGIN value
    | annotationBlock? opIdWrap compiledId? typeParam? opParameter typeEx? ASSGIN value
    | annotationBlock? aopIdWrap compiledId? typeParam? aopParameter typeEx? ASSGIN value
    | annotationBlock? TEMPLATE? ID compiledId? typeParam? parameter? (foreign|RawString)
    | annotationBlock? TEMPLATE? opIdWrap compiledId? typeParam? opParameter (foreign|RawString)
    | annotationBlock? TEMPLATE? aopIdWrap compiledId? typeParam? aopParameter (foreign|RawString)
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
    : LSQUARE lambdaParamEx* RSQUARE value
    ;

//// id utill
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

//// typeEx
typeEx
    : typeExParameter ARROW typeEx
    | typeExSingle
    ;
typeExSingle
    : (package_ DOT)? ID (LPAREN typeEx+ RPAREN)?
    ;
typeExParamEx
    : typeEx ELLIPSIS?
    ;
typeExParameter
    : LPAREN typeExParamEx* RPAREN
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



