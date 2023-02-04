grammar Folding;

////// Parser //////

file
    : namespace? importEx* (fileCompo|annotationDef)*
    ;
fileCompo
    : definition
    | SHARP field
    ;

//// import
importEx
    : IMPORT package_ importNest? importPath? importBody?
    ;
importBody: LBRACE importCompo* RBRACE ;
importCompo
    : ID (SHARP importAlias)? (As importType)?
    | CLASS ID (SHARP importAlias)?
    | CLASS QUOTE ID QUOTE (SHARP importAlias)?
    ;
importAlias: ID ;
importType: typeEx;
importPath: LPAREN FROM RawString RPAREN;
importNest: SHARP ID;

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
    : SHARP ID ASSGIN value #globalFieldAssign
    | value COLONSHARP ID ASSGIN value #objectFieldAssign
    ;

//// class
class_
    : annotationBlock? CLASS ID typeParam? LBRACE (COLON (defInInterface|def))* impl* RBRACE #justInterface
    | annotationBlock? CLASS ID typeParam? LBRACE constructorSelf (COLONSHARP field)* (COLON def)* inherit? impl* RBRACE #justClass
    | annotationBlock? CLASS ID typeParam? LBRACE constructorSelf? (COLONSHARP field)* (COLON (defInInterface|def))* inherit? impl* RBRACE #justAbstractClass
//    | annotationBlock? CLASS ID typeParam? LBRACE constructor_+ (COLONSHARP field)* (COLON (defInInterface|def))* inherit? impl* RBRACE #justMultiClass
    ;
constructor_
    : ID parameter? doBlock?
    ;
constructorSelf
    : parameter? doBlock?
    ;

defInInterface
    : annotationBlock? commonIdentifier typeParam? parameter? typeEx
    ;

//// impl
inherit
    : INHERIT argValue? impl
    ;
impl
    : IMPL typeEx implBody?
    ;
implBody
    : LBRACE (COLON def)* RBRACE
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
defaultValue: Integer | Double | String | boolean ;
boolean: TRUE | FALSE ;
value
    : defaultValue #justDefaultValue
    | NULL #null
    | ARROW (ID|QM) #outputOfInversing
    | QUOTE reference #reflected
    | reference argValue? #callFunction
    | NEW reference argValue? #useForeignClass
    | SHARP reference #getFieldGlobal
    | NEW LBRACE (COLONSHARP field)* (COLON def)* inherit? impl* RBRACE #anonymousClassObject
    | value typeCasting #valueTypeCasting
    | value COLONSHARP ID #getField
    | value COLON ID argValue? #callMethod
    | value COLONQUOTE ID #reflectedMethod
    | value DOUBLECOLON ID argValue? #callFunctionLikeMethod
    | value invoking #invokeValue
    | value IF value #simpleIf
    | value QM value #takeNull
    | callingAopId value #callAopFunc
    | value callingOpId value #callOpFunc
    | if_else #ifExpression
    | let_binding #letExpression
    | doBlock #doExpression
    | lambda #justLambda
    | LPAREN value RPAREN #parenedValue
    ;
reference
    : (package_ DOT)? commonIdentifier
    ;

typeCasting: LPAREN TILDE typeEx RPAREN ;

if_else
    : IF LPAREN value RPAREN value ELSE value
    ;
let_binding
    : LET value ASSGIN value value
    ;

//// parameter
paramEx
    : ID ELLIPSIS? TILDE typeEx
    ;
paramCEx
    : specificAlias? value TILDE typeEx
    ;
parameter
    : LPAREN paramEx+ RPAREN parameterFromValue?
    ;
parameterFromValue
    : FROM LPAREN paramCEx+ RPAREN
    ;
specificAlias: LPAREN ID ASSGIN RPAREN ;

//// argument
argEx
    : (ID ASSGIN)? value #singleArg
    | (ID ELLIPSIS)? LBRACE value* RBRACE #multiArg
    ;
argValue
    : LPAREN (typeEx+ TILDE)? argEx* RPAREN #primaryArgValue
    | LBRACE (typeEx+ TILDE)? value* RBRACE #singleListArgValue
    ;
invoking
    : COLON LPAREN value* RPAREN
    ;

//// identifier
commonIdentifier
    : ID
    | opIdWrap
    | aopIdWrap
    ;
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

callingOpId
    : OPID
    ;
callingAopId
    : OPID #commonAopId
    ;


//// definition
field: fieldSetted|fieldNotInit ;
fieldNotInit: ID (LPAREN MUTABLE RPAREN)? typeEx ;
fieldSetted: ID (LPAREN MUTABLE RPAREN)? typeEx? ASSGIN value ;
def
    : justDef inverseDefining*
    | foreignDef inverseDefining*
    ;

justDef
    : annotationBlock? commonIdentifier typeParam? parameter? typeEx ASSGIN value
    ;
foreignDef
    : annotationBlock? commonIdentifier typeParam? parameter? FOREIGN typeEx foreignBody?
    ;
inverseDefining
    : INVERSE ID? LPAREN inverseDefCompo+ RPAREN
    ;
inverseDefCompo
    : value (TILDE typeEx)? #outputParam
    | As ID #necessaryParam
    ;

//// lambda
lambda
    : LSQUARE parameterForLambda RSQUARE value
    ;
parameterForLambda
    : paramEx* parameterFromValueForLambda?
    ;
parameterFromValueForLambda
    : FROM paramCEx+
    ;

//// typeEx
typeEx
    : QM? typeExFunc
    | QM? typeExSingle
    ;
typeExSingle
    : (package_ DOT)? (ID|QUOTE ID QUOTE) (LPAREN typeEx+ RPAREN)?
    | primitiveType
    ;

primitiveType
    : INT|LONG|CHAR|STRING|BYTE|FLOAT|DOUBLE|BOOLEAN|UNIT
    | ARRAY LPAREN typeEx RPAREN
    ;
typeExParamEx
    : typeEx ELLIPSIS?
    ;
typeExFunc
    : LPAREN typeExParamEx* RPAREN ARROW typeEx
    ;

//// foreign
foreignBody: LBRACE foreignElement* RBRACE | RawString ;
foreignElement
    : foreignPlatform RawString
    ;
foreignPlatform: ID ;

//// annotation
annotationDef
    : ANNOTATION ID parameter
    ;
annotation
    : (package_ DOT)? ID argValue?
    ;
annotationBlock
    : LSQUARE annotation* RSQUARE
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
INVERSE: 'inverse' ;
FROM: 'from' ;
IF: 'if' ;
ELSE: 'else' ;
NEW: 'new' ;
LET: 'let' ;

// primitive type
INT: 'Int' ;
LONG: 'Long' ;
DOUBLE: 'Double' ;
FLOAT: 'Float' ;
BYTE: 'Byte' ;
CHAR: 'Char' ;
STRING: 'String' ;
BOOLEAN: 'Boolean' ;
UNIT: 'Unit' ;

ARRAY: 'Array' ;

// primitive value
NULL: 'null' ;
TRUE: 'true' ;
FALSE: 'false' ;

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
As: '~>' ;
COLON: ':' ;
DOUBLECOLON: '::' ;
COLONSHARP: ':#' ;
QUOTE: '\'' ;
COLONQUOTE: ':\'' ;
SHARP: '#' ;
QM: '?' ;

//// ID

fragment IDLETTERHEAD
    :   [_a-zA-Z]  ;

fragment IDLETTERTAIL
    :   [-_a-zA-Z0-9]  ;

fragment IDLETTERSPECIAL
    :   [-<>$.~|+=*&%^@!?/\\;,]  ;

ID: IDLETTERHEAD IDLETTERTAIL* ;
OPID: IDLETTERSPECIAL+ ;


//// default data struct

// nums
fragment DIGITLETTER
    :   [0-9]  ;

Integer: DIGITLETTER+ ;
Double: DIGITLETTER+ '.' DIGITLETTER+ ;

// string
String :  '"' (ESC | ~["\\])* '"' ;

fragment ESC :   '\\' (["\\/bfnrt] | UNICODE) ;
fragment UNICODE : 'u' HEX HEX HEX HEX ;
fragment HEX : [0-9a-fA-F] ;

RawString
    :   '`' (~[`])* '`'
    ;




