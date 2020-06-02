# MDSD Individual Portfolio

## BNF
SpringBoard ::= 'package' ':' Package 'models' ':' Model+ 'services' ':' Service+

Package ::= ID ('.' Package)?

Model ::= ID Inherits? '{' Field* '}'

Inherits ::= 'inherits' ID<sup>Type</sup>

Field ::= ID ':' Type (Invariant)?

Type ::= 'string' | 'datetime' | 'long | 'int' | 'bool' | 'float' | ID<sup>Type</sup> | 'list' 'of' Type | ID

Invariant ::= '[' Property Operator INT ']'

Property ::= 'length'

Operator ::= '<' | '>' | '=' | '<=' | '>=' | '<>'

Service ::= ID<sup>Type</sup> '{' CRUD? Method* '}'

CRUD ::= '[' 'C'?  'R'?  'U'?  'D'? ']'

Method ::= Request ID Input ':' Type RES

Request ::= 'local' | 'POST' | 'GET' | 'PUT' | 'DELETE'

RES ::= '{' Comparison '}'

Comparison ::= ARGS Operator Field

Input ::= Input '(' ARGS? ')'

ARGS :: = ID ':' Type (',' ARGS)?