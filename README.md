# MDSD Individual Portfolio

## BNF
**SpringBoard** ::= (*Template* | *Project*)+  
**Template** ::= 'template' ID 'models' ':' *Model*+ 'services' ':' *Service*+ 
**Project** ::= 'project' ID 'package' ':' *Package* ('uses' *ID<sup>Template</sup>*)? 'models' ':' *Model*+ 'services' ':' *Service*+  
**Package** ::= ID ('.' *Package*)?  
**Model** ::= (('extension' 'of' *ID<sup>Model</sup>*)? | ID *Inherits*?) '{' *Field** '}'  
**Inherits** ::= 'inherits' *ID<sup>Model</sup>*  
**Field** ::= ID ':' *Type* *Invariant*?  
**Type** ::= 'string' | 'datetime' | 'long | 'int' | 'bool' | 'float' | *ID<sup>Model</sup>* | 'list' 'of' *Type* | 'ID'  
**Invariant** ::= '[' *Property* *Operator* *INT* ']'   
**Property** ::= 'length'  
**Operator** ::= '<' | '>' | '=' | '<=' | '>=' | '<>'  
**Service** ::= ('extension' 'of')? *ID<sup>Model</sup>* '{' *CRUD*? *Method** '}'  
**CRUD** ::= '[' 'C'?  'R'?  'U'?  'D'? ']'  
**Method** ::= *Request* ID *Input* ':' *Type* *RES*  
**Request** ::= 'local' | 'POST' | 'GET' | 'PUT' | 'DELETE'  
**RES** ::= '{' *Comparison* '}'  
**Comparison** ::= *ARGS* *Operator* *Field*  
**Input** ::= *Input* '(' *ARGS*? ')'  
**ARGS** :: = ID ':' *Type* (',' *ARGS*)?

## Original Group BNF
**SpringBoard** ::= 'package' ':' *Package* *Models* *Services*  
**Package** ::= ID ('.' *Package*)?  
**Models** ::= 'models' ':' *Model*+  
**Model** ::= ID *Inherits*? '{' *Field** '}'  
**Inherits** ::= 'inherits' *ID<sup>Model</sup>*  
**Field** ::= ID ':' *Type* *Invariant*?  
**Type** ::= 'string' | 'datetime' | 'long | 'int' | 'bool' | 'float' | *ID<sup>Model</sup>* | 'list' 'of' *Type* | 'ID'  
**Invariant** ::= '[' *Property* *Operator* *INT* ']'  
**Property** ::= 'length'  
**Operator** ::= '<' | '>' | '=' | '<=' | '>=' | '<>'  
**Services** ::= 'services' ':' *Service*+  
**Service** ::= *ID<sup>Model</sup>* '{' *CRUD*? *Method** '}'  
**CRUD** ::= '[' 'C'?  'R'?  'U'?  'D'? ']'  
**Method** ::= *Request* ID *Input* ':' *Type* *RES*  
**Request** ::= 'local' | 'POST' | 'GET' | 'PUT' | 'DELETE'  
**RES** ::= '{' *Comparison* '}'  
**Comparison** ::= *ARGS* *Operator* *Field*  
**Input** ::= *Input* '(' *ARGS*? ')'  
**ARGS** :: = ID ':' *Type* (',' *ARGS*)?