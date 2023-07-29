grammar Folding;

////// Parser //////

file
    : namespace? importEx* (fileCompo|annotationDef|typeAlias)*
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
    : commonIdentifier (SHARP importDefAlias)? (As importType)?
    | CLASS commonClassIdentifier (SHARP importClassAlias)?
    ;
importDefAlias: commonIdentifier ;
importClassAlias: commonClassIdentifier ;
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
    : fieldAssign|remainLet_binding|value|returning
    ;
remainLet_binding
    : REMAIN let_binding
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
    : annotationBlock? ABSTRACT? INTERFACE? CLASS commonClassIdentifier (LPAREN typeParam RPAREN)? LBRACE (COLONSHARP fieldInInterface)* (COLON (defInInterface|def))* impl* RBRACE #justInterface
    | annotationBlock? DATA? CLASS commonClassIdentifier (LPAREN typeParam RPAREN)? LBRACE constructorSelf (COLONSHARP field)* (COLON def)* inherit? impl* RBRACE #justClass
    | annotationBlock? ABSTRACT? DATA? CLASS commonClassIdentifier (LPAREN typeParam RPAREN)? LBRACE constructorSelf? (COLONSHARP field)* (COLON (defInInterface|def))* inherit? impl* RBRACE #justAbstractClass
//    | annotationBlock? CLASS ID typeParam? LBRACE constructor_+ (COLONSHARP field)* (COLON (defInInterface|def))* inherit? impl* RBRACE #justMultiClass
    ;
constructor_ // Deprecated
    : ID parameter? doBlock?
    ;
constructorSelf
    : parameter? doBlock?
    ;

defInInterface
    : annotationBlock? commonIdentifier typeParam? parameter? typeEx
    ;
fieldInInterface
    : (LPAREN ABSTRACT RPAREN) fieldNotInit
    ;

//// impl
inherit
    : INHERIT argValue? impl
    ;
impl
    : IMPL typeEx implBody?
    ;
implBody
    : LBRACE (COLONSHARP field)* (COLON def)* RBRACE
    ;

//// type
typeParam
    : typeParamCompo+
    ;
typeParamCompo: commonClassIdentifier (TILDE typeEx)* ;


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
    | THIS #this
    | (ARROW (ID|QM) | ARROWQM) #outputOfInversing
    | QUOTE reference #reflected
    | reference argValue? #callFunction
    | NEW reference argValue? #useForeignClass
    | SHARP reference #getFieldGlobal
    | NEW LBRACE (COLONSHARP field)* (COLON def)* inherit? impl* RBRACE #anonymousClassObject
    | tupleEx #tuple
    | value typeCasting #valueTypeCasting
    | value COLONSHARP commonIdentifier #getField
    | value COLON commonIdentifier argValue? #callMethod
    | value COLONQUOTE commonIdentifier #reflectedMethod
    | value DOUBLECOLON commonIdentifier argValue? #callFunctionLikeMethod
    | value invoking #invokeValue
    | value TRIPLECOLON value invoking? #invokeValueLikeMethod
    | value (QUOTE commonOpIdentifier
            |LPAREN commonOpIdentifier RPAREN
            ) #callAopFuncBack
    | TILDE commonOpIdentifier value #callAopFunc
    | value (commonOpIdentifier value
            |LPAREN commonOpIdentifier value RPAREN
            ) #callOpFunc
    | value (IS typeEx
            |LPAREN IS typeEx RPAREN
            ) #typeCheck
    | value (IF value
            |LPAREN IF value RPAREN
            ) #simpleIf
    | if_else #ifExpression
    | patternMatch #patternMatchExpression
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

patternMatch
    : MATCH patternMatchCompo+
    ;
patternMatchCompo
    : patternValue=value (WHERE predicateValue=value)? ARROW outputValue=value
    ;

tupleEx
    : SHARP LPAREN value* RPAREN
    ;

//// parameter
paramEx
    : ID ELLIPSIS? TILDE typeEx
    ;
paramCEx
    : specificAlias? value TILDE typeEx
    ;
parameter
    : LPAREN paramEx+ parameterFromValue? RPAREN
    ;
parameterFromValue
    : FROM paramCEx+
    ;
specificAlias: LPAREN ID ASSGIN RPAREN ;

//// argument
argEx
    : (ID ASSGIN)? ELLIPSIS? value #singleArg
    | (ID ELLIPSIS)? LBRACE value* RBRACE #multiArg
    ;
argValue
    : LPAREN (typeEx+ PIPE)? argEx* RPAREN #primaryArgValue
    | LBRACE (typeEx+ PIPE)? value* RBRACE #singleListArgValue
    ;
invoking
    : COLON LPAREN value* RPAREN
    ;

//// identifier
commonOpIdentifier
    : OPID
    | commonIdentifier EM
    ;
commonIdentifier
    : ID
    | opIdWrap
    | aopIdWrap
    ;
opIdWrap: LSQUARE OPID RSQUARE ;
aopIdWrap: LSQUARE TILDE OPID RSQUARE ;

commonClassIdentifier
    : ID
    | QUOTE ID QUOTE
    ;



//// definition
field: fieldSetted|fieldNotInit|foreignField ;
fieldNotInit: (LPAREN MUTABLE RPAREN)? ID typeEx ;
fieldSetted: (LPAREN MUTABLE RPAREN)? ID typeEx? ASSGIN value ;
foreignField
    : LPAREN FOREIGN RPAREN ID typeEx
        (GET ASSGIN gettingValue=value)?
        (SET inputID=ID ASSGIN settingValue=value)?
    ;



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
    : (typeExFunc|LPAREN typeExFunc RPAREN QM?)
    | typeExSingle QM?
    ;
typeExSingle
    : (package_ DOT)? commonClassIdentifier (LPAREN typeArgEx+ RPAREN)?
    | primitiveType
    ;
typeArgEx
    : typeEx
    | typeExCovariant
    | typeExContravariant
    | typeExWildcard
    ;

primitiveType
    : INT|LONG|CHAR|STRING|BYTE|FLOAT|DOUBLE|BOOLEAN|UNIT
    ;
typeExParamEx
    : typeEx ELLIPSIS?
    ;
typeExFunc
    : LPAREN typeExParamEx* RPAREN ARROW typeEx
    ;

typeExCovariant
    : LSQUARE TILDE typeEx RSQUARE
    ;
typeExContravariant
    : LSQUARE typeEx TILDE RSQUARE
    ;
typeExWildcard
    : LSQUARE QM RSQUARE
    ;

//// foreign
foreignBody: LBRACE foreignElement* RBRACE | RawString ;
foreignElement
    : foreignPlatform RawString
    ;
foreignPlatform: ID ;

//// type alias
typeAlias
    : TYPEALIAS commonClassIdentifier (LPAREN typeParam RPAREN)?
        ( ASSGIN typeEx
        | FOREIGN foreignBody? foreignTypeExpectitive?
        )
    ;
foreignTypeExpectitive
    : EXPECT LBRACE (COLON defInInterface)* impl* RBRACE
    ;

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

ABSTRACT: 'abstract' ;
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
INTERFACE: 'interface' ;
DATA: 'data' ;
INVERSE: 'inverse' ;
EXPECT: 'expect' ;
IF: 'if' ;
ELSE: 'else' ;
NEW: 'new' ;
LET: 'let' ;
TYPEALIAS: 'typealias' ;
WHERE: 'where' ;

// extra keywords
FROM: 'from!' ;
IS: 'is!' ;
GET: 'get!' ;
SET: 'set!' ;
REMAIN: 'remain!' ;
MATCH: 'match!' ;

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

// primitive value
NULL: 'null' ;
TRUE: 'true' ;
FALSE: 'false' ;

THIS: 'this' ;

//// Signs

PIPE: '|' ;
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
ARROWQM: '->?' ;
TILDE: '~' ;
As: '~>' ;
COLON: ':' ;
DOUBLECOLON: '::' ;
TRIPLECOLON: ':::' ;
COLONSHARP: ':#' ;
QUOTE: '\'' ;
COLONQUOTE: ':\'' ;
SHARP: '#' ;
QM: '?' ;
EM: '!' ;

//// ID

fragment IDLETTERHEAD
    :   [_a-zA-Z]  ;

fragment IDLETTERTAIL
    :   [-_a-zA-Z0-9]  ;

fragment IDLETTERSPECIAL
    :   [-<>$.|+=*&%^@!?/\\:;,]  ;

ID: IDLETTERHEAD IDLETTERTAIL* ;
OPID: IDLETTERSPECIAL+ ;


//// default data struct

// nums
fragment DIGITLETTER
    :   [0-9]  ;

Integer: DIGITLETTER+ | '0x'HEX+ ;
Double: DIGITLETTER+ '.' DIGITLETTER+ ;

// string
String :  '"' (ESC | ~["\\])* '"' ;

fragment ESC :   '\\' (["\\/bfnrt] | UNICODE) ;
fragment UNICODE : 'u' HEX HEX HEX HEX ;
fragment HEX : [0-9a-fA-F] ;

RawString
    :   '`' (~[`])* '`'
    ;




