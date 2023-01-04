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
    : IMPORT package_ importPath? importBody?
    ;
importBody: LBRACE importCompo* RBRACE ;
importCompo
    : ID (SHARP importAlias)? (As importType)?
    | CLASS ID (SHARP importAlias)?
    | CLASS QUOTE ID QUOTE (SHARP importAlias)?
    ;
importAlias: ID ;
importType: typeEx;
importPath: RawString;

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
    | annotationBlock? CLASS ID typeParam? LBRACE constructor_+ (COLONSHARP field)* (COLON (defInInterface|def))* inherit? impl* RBRACE #justMultiClass
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
    : INHERIT impl
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
defaultValue: Integer | Double | String ;
value
    : defaultValue #justDefaultValue
    | NULL #null
    | ARROW ID #outputOfInversing
    | QUOTE reference #reflected
    | reference argValue? #callFunction
    | NEW reference argValue? #useForeignClass
    | SHARP reference #getFieldGlobal
    | LBRACE TILDE (COLONSHARP field)* (COLON def)* inherit? impl* RBRACE #anonymousClassObject
    | value COLONSHARP ID #getField
    | value COLON ID argValue? #callMethod
    | value COLONQUOTE ID #reflectedMethod
    | value invoking #invokeValue
    | value IF value #simpleIf
    | value QM value #takeNull
    | if_else #ifExpression
    | value typeCasting #valueTypeCasting
    | callingAopId value #callAopFunc
    | value callingOpId value #callOpFunc
    | doBlock #doExpression
    | lambda #justLambda
    | LPAREN value RPAREN #parenedValue
    ;
reference
    : (package_ DOT)? commonIdentifier
    ;

typeCasting: As typeEx ;

if_else
    : IF LPAREN value RPAREN value ELSE value #directJudge
    | IF LPAREN value (SHARP ID)? ARROW value RPAREN value ELSE value #bindingJudge
    ;

//// parameter
paramEx
    : ID ELLIPSIS? TILDE typeEx
    ;
paramCEx
    : specificAlias? value TILDE typeEx
    ;
parameter
    : LPAREN paramEx* RPAREN parameterFromValue?
    ;
parameterFromValue
    : FROM LPAREN paramCEx+ RPAREN
    ;
specificAlias: LPAREN ID TILDE RPAREN ;

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
    : OPID #commonOpId
    | (PLUS|MINUS|MULTIPLY|DIVIDE) #primitiveOpId
    ;
callingAopId
    : OPID #commonAopId
    | (PLUS|MINUS) #primitiveAopId
    ;


//// definition
field: fieldSetted|fieldNotInit ;
fieldNotInit: ID (LPAREN MUTABLE RPAREN)? typeEx ;
fieldSetted: ID (LPAREN MUTABLE RPAREN)? typeEx? ASSGIN value ;
def
    : justDef inverseDefining*
    | foreignDef
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
    : typeEx value #outputParam
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
    : INT|CHAR|STRING|BYTE|FLOAT|DOUBLE|BOOLEAN|UNIT
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
    : (package_ DOT)? ID argValue
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

// primitive type
INT: 'Int' ;
DOUBLE: 'Double' ;
FLOAT: 'Float' ;
BYTE: 'Byte' ;
CHAR: 'Char' ;
STRING: 'String' ;
BOOLEAN: 'Boolean' ;
UNIT: 'Unit' ;

// primitive value
NULL: 'null' ;

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
COLONSHARP: ':#' ;
QUOTE: '\'' ;
COLONQUOTE: ':\'' ;
SHARP: '#' ;
QM: '?' ;

PLUS: '+' ;
MINUS: '-' ;
MULTIPLY: '*' ;
DIVIDE: '/' ;

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
String :  '"' (ESC | ~["\\])* '"' ;

fragment ESC :   '\\' (["\\/bfnrt] | UNICODE) ;
fragment UNICODE : 'u' HEX HEX HEX HEX ;
fragment HEX : [0-9a-fA-F] ;

RawString
    :   '`' (~[`])* '`'
    ;




