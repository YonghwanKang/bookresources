%{
#include "cic.h"
short int varCount;
#define MAXVARIABLES 10
#define MAXVARSIZE 20
char varNames[MAXVARIABLES][MAXVARSIZE];
int i;
char *ptr;
int numDim;
char labelpending[LABELSIZE];
short int dataSize;
short int structSize=0;
short int dataType=DEFAULT;
short int storeType=DEFAULT;
short int qualifierType=DEFAULT;
short int signType=DEFAULT;
short int widthType=DEFAULT;
short int dataTypeDeclared=FALSE;
short int storeTypeDeclared=FALSE;
short int qualifierTypeDeclared=FALSE;
short int structOrUnion=FALSE;
short int operatorType;
short int assignOpr;

int caseIdx,noCases;
extern int lineNo;
char tempLabel[LABELSIZE];
char caseExpr[NAMESIZE];
char caseLabel[LABELSIZE];
typedef struct TFLABEL
{	
	char trueLabel[LABELSIZE];
  	char falseLabel[LABELSIZE];
}TFLABEL;
TFLABEL tflabel;

extern LNode* findSymbolHash(ST*,char*);
LNode* L;
Attr opnd1,opnd2,result,noAttr;
%}
%union
{
  char name[NAMESIZE];
  int no;
  Attr attr;
  
  /*Label label;*/
  struct tfLabel
  {	
	char trueLabel[LABELSIZE];
  	char falseLabel[LABELSIZE];
  }tflabel;
 struct ForLabel
 {
	char cond2Label[LABELSIZE];
	char cond3Label[LABELSIZE];
	char cond2TestLabel[LABELSIZE];
	char nextStmtLabel[LABELSIZE];
 }forLabel;
};
%left _or
%left _and
%left _equal _ne
%left _lt _le _gt _ge
%left _minus _plus
%left _mul _div
%nonassoc _uminus
%token _assign _typedef _extern _static _auto _register _void _char _short _if _else
%token _int _long _float _double _signed _unsigned _Bool _Complex _leftb  _rightb
%token _struct _union _colon _enum _const _restrict _volatile _inline _leftp _rightp
%token _static _mul _dot _comma _leftb _rightb _num _dnum _charcons _strcons _leftsp _rightsp
%token _dereferencing _incr _decr _sizeof _mul _plus _uminus _tilde _bang _div 
%token _modulo _minus _lShift _rSignedShift _lt _gt _le _ge _eq _ne 
%token _bitAnd _xor _or _and _or _hook _mulAssign _divAssign _moduloAssign _plusAssign
%token _minusAssign _lShiftAssign _rSignedShiftAssign _andAssign _xorAssign _orAssign
%token _colon _case _default _switch _while _do _for _semicolon _goto _bitOr
%token _continue _break _return _id _Imaginary _rUnsignedShift _rUnsignedShiftAssign
%token <attr> _id
%token  <attr> _num
%token  <attr> _dnum
%token <attr> _id
%token <attr> _charcons
%token <attr> _strcons
%type <attr> functionDefinition
%type <attr> identifier
%type <attr> initDeclarator
%type <attr> declarator
%type <attr> directDeclarator
%type <attr> constant
%type <attr> stringLiteral
%type <attr> primaryExpression
%type <attr> postfixExpression
%type <attr> unaryExpression
%type <attr> castExpression
%type <attr> multiplicativeExpression
%type <attr> additiveExpression
%type <attr> expression
%type <attr> typeName
%type <attr> shiftExpression
%type <attr> relationalExpression
%type <attr> equalityExpression
%type <attr> andExpression
%type <attr> exclusiveOrExpression
%type <attr> inclusiveOrExpression
%type <attr> logicalAndExpression
%type <attr> logicalOrExpression
%type <attr> conditionalExpression
%type <attr> assignmentExpression
%type <attr> assignmentExpressionopt
%type <attr> expression
%type <attr> constantExpression
%type <attr> statement
%type <attr> matchedStatement
%type <attr> unmatchedStatement
%type <attr> ifexprMatchedStatementElse
%type <attr> switchCaseStatement
%type <attr> labeledStatement
%type <attr> compoundStatement
%type <attr> blockItemList
%type <attr> expressionStatement
%type <attr> expressionopt
%type <attr> iterationStatement
%type <attr> identifieropt
%type <attr> enumerationConstant
%type <attr> abstractDeclarator
%type <attr> pointeropt
%type <attr> pointer
%type <attr> ifexpr
%type <attr> structOrUnionSpecifier
%type <attr> structDeclarator
%token <forLabel> _for
%token <tflabel> _while
%token <tflabel> _if
%token <tflabel> _do
%token <tflabel> _switch
%%
program:	
		{
			prevst=NULL;
			st = NULL;
			cst=NULL;
			fst=NULL;
			gst=NULL;
			cstackTop=-1;
			bstackTop=-1;
			st = (ST*)malloc(sizeof(ST));
			if(st==NULL) 
			{
				printf("Error: Memory allocation Problem for Symbol Table..Existing\n");
				exit(-1);
			}
			strcpy(st->funcName,"global");
			st->prevst=prevst;
			prevst=st;
			gst=st;
			initHash(st,HASHSIZE);
			createQuadList(&quadTable);
			

  		}
translationUnit 
		{	
			if(errCount > 0)
			{
				printf("Error occured in compiling the source program\n");
				exit(-1);
				
			}
			return;
		}
	;
translationUnit: externalDeclaration 
|translationUnit externalDeclaration
	;
externalDeclaration: functionDefinition 
|  declaration 
	;
functionDefinition: declarationSpecifiers declarator 
		{
			sym.nameLen = strlen($2.name);
			sym.name = malloc(sym.nameLen+1);
			strcpy(sym.name,$2.name);
			sym.storage = storeType;
			sym.qualifier = qualifierType;
			sym.sign=signType;
			sym.widthType=widthType;
		 	sym.type = FUNCTION; 
			sym.subtype = dataType;
			sym.width = sizeof(Symbol);//dataSize;
			sym.dimArray=NULL;
			sym.structLink=NULL; 
			sym.st=NULL; 
			sym.relAddr=relAddr;
			relAddr = relAddr + sym.width;
			sym.st=NULL;
			
			signType=DEFAULT;
			widthType=DEFAULT;
			storeType=DEFAULT;
			qualifierType=DEFAULT;
			dataType=DEFAULT;
			dataTypeDeclared=FALSE;
			storeTypeDeclared=FALSE;
			qualifierTypeDeclared=FALSE;			
			strcpy($$.name,$2.name);
		}
declarationListopt 
		{
			opnd1.type=NOP;
			strcpy(opnd1.name," ");
			opnd1.type=NOP;
			strcpy(opnd2.name," ");
			result.type=FUNCTION;
			strcpy(result.name,$2.name);			
			addCode(quadTable,$2.name,FUNCTION,opnd1,opnd2,result);	

		}
compoundStatement 
		{
			opnd1.type=NOP;
			strcpy(opnd1.name," ");
			opnd1.type=NOP;
			strcpy(opnd2.name," ");
			result.type=RETURN;
			strcpy(result.name," ");			
			addCode(quadTable," ",RETURN,opnd1,opnd2,result);
			strcpy(labelpending," ");
			st=st->prevst; 
		}
	;
declarationListopt:	|declarationList
	;
declarationList: declaration
|declarationList declaration
	;
declaration:  declarationSpecifiers  initDeclaratorListopt _semicolon 
	{
		signType=DEFAULT;
		widthType=DEFAULT;
		storeType=DEFAULT;
		qualifierType=DEFAULT;
		dataType=DEFAULT;
		dataTypeDeclared=FALSE;
		storeTypeDeclared=FALSE;
		qualifierTypeDeclared=FALSE;
	} 
	;
declarationSpecifiers: storageClassSpecifier declarationSpecifiersopt 
| typeSpecifier  declarationSpecifiersopt 
| typeQualifier declarationSpecifiersopt
| functionSpecifier declarationSpecifiersopt
	;
declarationSpecifiersopt:	|declarationSpecifiers
	;
storageClassSpecifier: 	_auto 	
		{
			if(TRUE==storeTypeDeclared)
			{
				printf("%d->Error: Two or more number of storage declarations\n",lineNo+1); errCount++;
			}
			else
			{
				storeType = AUTO;
				storeTypeDeclared=TRUE;
			}
		}
	|_register		
		{
			if(TRUE==storeTypeDeclared)
			{
				printf("%d->Error: Two or more number of storage declarations\n",lineNo+1); errCount++;
			}
			else
			{
				storeType = REGISTER;
				storeTypeDeclared=TRUE;
			}
		}
	|_static		
		{
			if(TRUE==storeTypeDeclared)
			{
				printf("%d->Error: Two or more number of storage declarations\n",lineNo+1); errCount++;
			}
			else
			{
				storeType = STATIC;
				storeTypeDeclared=TRUE;
			}
		}
	|_extern
		{
			if(TRUE==storeTypeDeclared)
			{
				printf("%d->Error: Two or more number of storage declarations\n",lineNo+1); errCount++;
			}
			else
			{
				storeType = EXTERN;
				storeTypeDeclared=TRUE;
			}
		}
	|_typedef		
		{
			if(TRUE==storeTypeDeclared)
			{
				printf("%d->Error: Two or more number of storage declarations\n",lineNo+1);errCount++;
			}
			else
			{
				storeType = TYPEDEF;
				storeTypeDeclared=TRUE;
			}
		}
	;
typeSpecifier:  signOpt	_char	
		{

			if(TRUE==dataTypeDeclared)
			{
				printf("%d->Error: Two or more number of type declarations\n",lineNo+1); errCount++;
			}
			else
			{
				dataType = CHAR;
				dataSize=sizeof(char);
				dataTypeDeclared=TRUE;
			}	
		}		
|signOpt widthOpt _int   
		{
			if(TRUE==dataTypeDeclared)
			{
				printf("%d->Error: Two or more number of type declarations\n",lineNo+1); errCount++;
			}
			else
			{
				dataType = INT;
				if(widthType==SHORT)
					dataSize=sizeof(short int);
				else if(widthType==LONG)
					dataSize=sizeof(long int);
				else
					dataSize=sizeof(int);
				dataTypeDeclared=TRUE;
			}
		}

|_float 
		{
			if(TRUE==dataTypeDeclared)
			{
				printf("%d->Error: Two or more number of type declarations\n",lineNo+1); errCount++;
			}
			else
			{
				dataType = FLOAT;
				dataSize=sizeof(float);
				dataTypeDeclared=TRUE;
			}
		}
|_double
		{
			if(TRUE==dataTypeDeclared)
			{
				printf("%d->Error: Two or more number of type declarations\n",lineNo+1); errCount++;
			}
			else
			{
				dataType = DOUBLE;
				dataSize=sizeof(double);
				dataTypeDeclared=TRUE;
			}
			
		}
|_Bool  
		{
			dataType = BOOL;
			dataSize=sizeof(short int);	//  has to be updated
		}
|_Complex 
		{
			dataType = COMPLEX;
			dataSize=sizeof(2*sizeof(double)); //  has to be updated
		}
|structOrUnionSpecifier 
		{
			//dataType = STRUCTORUNION;
			//dataSize=sizeof(2*sizeof(int)); //  has to be updated
		}
|enumSpecifier
		{
			dataType = ENUM;
			dataSize=sizeof(2*sizeof(int)); //has to be updated
		}
	;
widthOpt:	|_short 
		{
			widthType = SHORT;
			
		}
|_long  
		{
			widthType = LONG;
			
		}
	;
signOpt: 	|_signed 
		{
			signType = SIGNED;
		}
|_unsigned 
		{
			signType = UNSIGNED;
		}
	;
typeQualifier: _const 
		{
			if(TRUE==qualifierTypeDeclared)
			{
				printf("%d->Error: Two or more number of qualifier declarations\n",lineNo+1); errCount++;
			}
			else
			{
				qualifierType = CONST;
				qualifierTypeDeclared=TRUE;
			}
			
		}
|_restrict	{
			if(TRUE==qualifierTypeDeclared)
			{
				printf("%d->Error: Two or more number of qualifier declarations\n",lineNo+1);errCount++;
			}
			else
			{
				qualifierType = RESTRICT;
				qualifierTypeDeclared=TRUE;
			}
			
		}
|_volatile	{
			if(TRUE==qualifierTypeDeclared)
			{
				printf("%d->Error: Two or more number of qualifier declarations\n",lineNo+1); errCount++;
			}
			else
			{
				qualifierType = VOLATILE;
				qualifierTypeDeclared=TRUE;
			}
			
		}
	;
functionSpecifier: _inline
	;

initDeclaratorListopt: 	|initDeclaratorList
	;
initDeclaratorList: initDeclarator 
		{
			sym.nameLen = strlen($1.name);
			sym.name = malloc(sym.nameLen+1);
			strcpy(sym.name,$1.name);
			sym.storage = storeType;
			sym.qualifier = qualifierType;
			sym.sign=signType;
			sym.widthType=widthType;
		 	sym.type = BASIC; 
			sym.subtype = dataType;
			sym.width = dataSize;
			sym.dimArray=NULL;
			sym.structLink=NULL; 
			sym.st=NULL; 
			sym.relAddr=relAddr;
			switch(sym.subtype)
			{
				case INT:
					sym.value.iVal=0;
					break;
				case DOUBLE:
					sym.value.dVal=0.0;
					break;
				case CHAR:
					sym.value.cVal=' ';
					break;
				case STRING:
					sym.value.sVal=NULL;
					break;
			}
			relAddr = relAddr + sym.width;
			addSymbolHash(st,sym);


		}	
|initDeclaratorList _comma initDeclarator 
		{
			sym.nameLen = strlen($3.name);
			sym.name = malloc(sym.nameLen+1);
			strcpy(sym.name,$3.name);
			sym.storage = storeType;
			sym.qualifier = qualifierType;
			sym.sign=signType;
			sym.widthType=widthType;
		 	sym.type = BASIC; 
			sym.subtype = dataType;
			sym.width = dataSize;
			sym.dimArray=NULL;
			sym.structLink=NULL;
			sym.st=NULL;
			sym.relAddr=relAddr;
			switch(sym.subtype)
			{
				case INT:
					sym.value.iVal=0;
					break;
				case DOUBLE:
					sym.value.dVal=0.0;
					break;
				case CHAR:
					sym.value.cVal=' ';
					break;
				case STRING:
					sym.value.sVal=NULL;
					break;
			}
			relAddr = relAddr + sym.width;
			addSymbolHash(st,sym);
		}	
	;
initDeclarator:  declarator 	{strcpy($$.name,$1.name);}
|declarator _assign initializer
	;

structOrUnionSpecifier: structOrUnion 
identifieropt 
		{
			cst = st;
			sym1.nameLen = strlen($2.name);
			sym1.name = malloc(sym1.nameLen+1);
			strcpy(sym1.name,$2.name);
			sym1.storage = DEFAULT;
			sym1.qualifier = DEFAULT;
			sym1.sign=DEFAULT;
			sym1.widthType=DEFAULT;
		 	sym1.type = STRUCT; 
			sym1.subtype = DEFAULT;
			sym1.dimArray=NULL;
			sym1.st=NULL;
			sym1.structLink=(ST*)malloc(sizeof(ST));
			if(sym1.structLink == NULL) 
			{
				printf("Error: Memory allocation Problem for Symbol Table..Existing\n");
				exit(-1);
			}
			
			initHash(sym1.structLink,HASHSIZE);
			st=sym1.structLink;
			sym1.relAddr=relAddr;
			//Sym1.value has to be appropriately initialized
			structSize=0;
			
		}
_leftb structDeclarationList _rightb 
		{
			sym1.structLink=st;
			sym1.width = structSize;
			relAddr = relAddr + sym1.width;
			st=cst;
			addSymbolHash(st,sym1);
			structOrUnion=FALSE;
			
		}
|structOrUnion identifier
	;
structOrUnion: _struct
		{
			structOrUnion=STRUCT;
		}
|_union
		{
			structOrUnion=UNION;
		}
	;
structDeclarationList: structDeclaration
|structDeclarationList structDeclaration
	;
structDeclaration: specifierQualifierList structDeclaratorList _semicolon
	;
specifierQualifierList: typeSpecifier specifierQualifierListopt
|typeQualifier specifierQualifierListopt
	;
specifierQualifierListopt:	|specifierQualifierList
	;
structDeclaratorList: structDeclarator
		{
			sym.nameLen = strlen($1.name);
			sym.name = malloc(sym.nameLen+1);
			strcpy(sym.name,$1.name);
			sym.storage = storeType;
			sym.qualifier = qualifierType;
			sym.sign=signType;
			sym.widthType=widthType;
		 	sym.type = BASIC; 
			sym.subtype = dataType;
			sym.width = dataSize;
			sym.dimArray=NULL;
			sym.structLink=NULL;
			sym.st=NULL;
			sym.relAddr=relAddr;
			//Sym.value has to be appropriately initialized
			relAddr = relAddr + sym.width;
			addSymbolHash(st,sym);

			if(structOrUnion==STRUCT)
				structSize += dataSize;
			else if (structOrUnion==UNION)
				structSize = structSize > dataSize ? structSize:dataSize;
			signType=DEFAULT;
			widthType=DEFAULT;
			storeType=DEFAULT;
			qualifierType=DEFAULT;
			dataType=DEFAULT;
			dataTypeDeclared=FALSE;   ////To be checked it it does not work
			storeTypeDeclared=FALSE;
			qualifierTypeDeclared=FALSE;	
		}
|structDeclaratorList _comma structDeclarator
		{
			sym.nameLen = strlen($3.name);
			sym.name = malloc(sym.nameLen+1);
			strcpy(sym.name,$3.name);
			sym.storage = storeType;
			sym.qualifier = qualifierType;
			sym.sign=signType;
			sym.widthType=widthType;
		 	sym.type = BASIC; 
			sym.subtype = dataType;
			sym.width = dataSize;
			sym.dimArray=NULL;
			sym.structLink=NULL;
			sym.st=NULL;
			//Sym.value has to be appropriately initialized
			sym.relAddr=relAddr;
			relAddr = relAddr + sym.width;
			addSymbolHash(st,sym);

			if(structOrUnion==STRUCT)
				structSize += dataSize;
			else if (structOrUnion==UNION)
				structSize = structSize > dataSize ? structSize:dataSize;
			dataTypeDeclared=FALSE;   
			storeTypeDeclared=FALSE;
			qualifierTypeDeclared=FALSE;	
		}
	;
structDeclarator: declarator  {$$=$1;}
		
				
|declaratoropt _colon constantExpression
	;
declaratoropt:	|declarator
	;
enumSpecifier: _enum identifieropt _leftb enumeratorList _rightb
|_enum identifieropt _leftb enumeratorList _comma _rightb
|_enum identifier
	;
identifieropt:	|identifier 
		{
			strcpy($$.name,$1.name);
		}
	;
enumeratorList: enumerator
|enumeratorList _comma enumerator
	;
enumerator: enumerationConstant
|enumerationConstant _assign constantExpression
	;
enumerationConstant:	identifier 
		{
			strcpy($$.name,$1.name);
		}
	;

declarator: pointeropt  directDeclarator 
		{
			strcpy($$.name,$2.name);
		}
	;
pointeropt:	|pointer {$$=$1;}
	;
directDeclarator: identifier {strcpy($$.name,$1.name);}
|_leftp declarator _rightp	{$$=$2;}
|directDeclarator _leftsp typeQualifierListopt assignmentExpressionopt _rightsp
|directDeclarator _leftsp _static typeQualifierListopt assignmentExpression _rightsp
|directDeclarator _leftsp typeQualifierList _static assignmentExpression _rightsp
|directDeclarator  _leftsp typeQualifierListopt _mul _rightsp
|directDeclarator _leftp parameterTypeList _rightp
|directDeclarator _leftp identifierListopt _rightp
	;
identifierListopt:	|identifierList 
	;
typeQualifierListopt:	|typeQualifierList
	;
assignmentExpressionopt:	|assignmentExpression {$$=$1;}
	;
pointer: _mul typeQualifierListopt
|_mul typeQualifierListopt pointer
	;
typeQualifierList: typeQualifier
|typeQualifierList typeQualifier
	;
parameterTypeList: parameterList
|parameterList _comma _dot _dot _dot
	;
parameterList: parameterDeclaration
|parameterList _comma parameterDeclaration
	;
parameterDeclaration: declarationSpecifiers declarator
|declarationSpecifiers abstractDeclaratoropt
	;
abstractDeclaratoropt:	|abstractDeclarator
	;
identifierList: identifier 
|identifierList _comma identifier
	;
typeName: specifierQualifierList abstractDeclaratoropt
	;
abstractDeclarator: pointer  {$$=$1;}
|pointeropt directAbstractDeclarator
	;
directAbstractDeclarator: _leftp abstractDeclarator _rightp
|directAbstractDeclaratoropt _leftsp assignmentExpressionopt _rightsp
|directAbstractDeclaratoropt _leftsp _mul _rightsp
|directAbstractDeclaratoropt _leftp parameterTypeListopt _rightp
	;
directAbstractDeclaratoropt:	 | directAbstractDeclarator 
	;
parameterTypeListopt:	|parameterTypeList
	;
initializer: assignmentExpression
|_leftb initializerList _rightb
|_leftb initializerList _comma _rightb
	;
initializerList: designationopt initializer
|initializerList _comma designationopt initializer
	;
designationopt:	|designation
	;
designation: designatorList _assign
	;
designatorList: designator
|designatorList designator
	;
designator: _leftsp constantExpression _rightsp
|_dot identifier
	;

constant:	_num 
		{ $$=$1; }
|_dnum		     
		{ $$=$1;}
|_charcons	     
		{ $$=$1; }
	;	
stringLiteral:	_strcons 
		{ $$=$1; }
	;

primaryExpression:	identifier  
		{ 	
			int found = FALSE;
			cst = st;
			while(cst != NULL)
			{
				if(findSymbolHash(cst,$1.name) != NULL)
				{
					found=TRUE;
					break;
				}
				else
				{
					cst=cst->prevst;
				}
			}
			if(found == FALSE)
			{
				printf("....%s: %d:Error %s: Undeclared Identifier\n",srcFileName,lineNo-1,$1.name);
				errCount++;
			}
			else
			{ //printf("%s is found here\n",$1.name);
				$$=$1;
				strcpy($$.offsetName,"");
			}

		} 
| constant      
		{ $$=$1;}
| stringLiteral 
		{ $$=$1; }
|_leftp expression _rightp 
		{ $$=$2; }
	;
postfixExpression: primaryExpression  	
		{ $$=$1; }
| postfixExpression _leftsp expression _rightsp
| postfixExpression _leftp argumentExpressionListopt _rightp
| postfixExpression _dot identifier
| postfixExpression _dereferencing identifier
| postfixExpression _incr
| postfixExpression _decr
|_leftp typeName _rightp _leftb initializerList _rightb
|_leftp typeName _rightp _leftb initializerList _comma _rightb
	;
argumentExpressionListopt:	|argumentExpressionList
	;
argumentExpressionList: assignmentExpression
|argumentExpressionList _comma assignmentExpression
	;
unaryOperator: _bitAnd  {operatorType = UBITAND;}
|_mul   	{operatorType = UMUL;}
|_plus 		{operatorType = UPLUS;}
|_uminus 	{operatorType = UMINUS;}
|_tilde  	{operatorType = UTILDE;}
|_bang   	{operatorType = UBANG;}
	;
unaryExpression: postfixExpression 
		{
			$$ = $1;
	   	}
|_incr unaryExpression
		{
	  		createTemp($$.name);
			noAttr.type = NOP;
	  		addCode(quadTable,labelpending,INCR,$2,noAttr, $$);
	   		sym=copySymbol(st,$2,$$.name);
	   		addSymbolHash(st,sym);
		}
|_decr unaryExpression
		{
	  		createTemp($$.name);
			noAttr.type = NOP;
	  		addCode(quadTable,labelpending,DECR,$2,noAttr, $$);
	   		sym=copySymbol(st,$2,$$.name);
	   		addSymbolHash(st,sym);
		}
|unaryOperator castExpression
		{
	  		createTemp($$.name);
			noAttr.type = NOP;
	  		addCode(quadTable,labelpending,operatorType,$2,noAttr, $$);
	   		sym=copySymbol(st,$2,$$.name);
	   		addSymbolHash(st,sym);
		}
|_sizeof unaryExpression
		{
	  		createTemp($$.name);
			noAttr.type = NOP;
	  		addCode(quadTable,labelpending,SIZEOF,$2,noAttr, $$);
	   		sym=copySymbol(st,$2,$$.name);
	   		addSymbolHash(st,sym);
		}
|_sizeof _leftp typeName _rightp
		{
	  		createTemp($$.name);
			noAttr.type = NOP;
	  		addCode(quadTable,labelpending,USERSIZEOF,$3,noAttr, $$);
	   		sym=copySymbol(st,$3,$$.name);
	   		addSymbolHash(st,sym);
		}
	;
castExpression: unaryExpression
		{
			$$ = $1;
	   	}
|_leftp typeName _rightp castExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,TYPECAST,$2,$4,$$);
	   		sym=createTempSymbolWithType(st,$2,$4,$$);  //to be updated
	   		addSymbolHash(st,sym);
		}
	;
multiplicativeExpression: castExpression
		{
			$$ = $1;
	   	}
|multiplicativeExpression _mul castExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,MUL,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|multiplicativeExpression _div castExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,DIV,$1,$3,$$);
  	 		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|multiplicativeExpression _modulo castExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,MODULO,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
additiveExpression: multiplicativeExpression
		{
			$$ = $1;
	   	}
|additiveExpression _plus multiplicativeExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,PLUS,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|additiveExpression _minus multiplicativeExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,MINUS,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
shiftExpression: additiveExpression
		{
			$$ = $1;
	   	}
|shiftExpression _lShift additiveExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,LSHIFT,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|shiftExpression _rSignedShift additiveExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,RSHIFTSIGNED,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
relationalExpression: shiftExpression
		{
			$$ = $1;
	   	}
|relationalExpression _lt shiftExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,LT,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|relationalExpression _gt shiftExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,GT,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|relationalExpression _le shiftExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,LE,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|relationalExpression _ge shiftExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,GE,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
equalityExpression: relationalExpression
		{
			$$ = $1;
	   	}
|equalityExpression _eq relationalExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,EQ,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
|equalityExpression _ne relationalExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,NE,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
andExpression: equalityExpression
		{
			$$ = $1;
	   	}
|andExpression _bitAnd  equalityExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,BITAND,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
exclusiveOrExpression: andExpression
		{
			$$ = $1;
	   	}
|exclusiveOrExpression _xor andExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,XOR,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
inclusiveOrExpression: exclusiveOrExpression
		{
			$$ = $1;
	   	}
|inclusiveOrExpression _bitOr exclusiveOrExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,BITOR,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
logicalAndExpression: inclusiveOrExpression
		{
			$$ = $1;
	   	}
|logicalAndExpression _and inclusiveOrExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,AND,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
logicalOrExpression: logicalAndExpression
		{
			$$ = $1;
	   	}
|logicalOrExpression _or logicalAndExpression
		{
	   		createTemp($$.name);
	   		addCode(quadTable,labelpending,OR,$1,$3,$$);
	   		sym=createTempSymbolWithType(st,$1,$3,$$);
	   		addSymbolHash(st,sym);
                }
	;
conditionalExpression: logicalOrExpression
		{
			$$ = $1;
	   	}
|logicalOrExpression _hook expression _colon conditionalExpression
		{
	   		createLabel(tflabel.trueLabel);
			createLabel(tflabel.falseLabel);
			createTemp($$.name);
			opnd2.type=NOP;
			result.type=LABEL;
			strcpy(result.name,tflabel.trueLabel);
	   		addCode(quadTable,labelpending,IFGO,$1,opnd2,result);
			addCode(quadTable,labelpending,ASSIGN,$5,opnd2,$$);   //false part assigned
			sym=createTempSymbolWithType(st,$3,$3,$$);  
			result.type=LABEL;
			strcpy(result.name,tflabel.falseLabel);
			addCode(quadTable,labelpending,GOTO,opnd2,opnd2,result); //goto end of this conditional expression
			strcpy(labelpending,tflabel.trueLabel);	  
			addCode(quadTable,labelpending,ASSIGN,$3,opnd2,$$);  //true part assigned and follows to the IC with labelpending
			sym=createTempSymbolWithType(st,$5,$5,$$);
			strcpy(labelpending,tflabel.trueLabel);	   		
			addSymbolHash(st,sym);
                }
	;
assignmentExpression: conditionalExpression
		{
			$$ = $1; 
	   	}
|unaryExpression assignmentOperator assignmentExpression
		{
			
			switch(assignOpr)
			{
				case ASSIGN: 
					opnd2.type = NOP;
					addCode(quadTable,labelpending,assignOpr,$3,opnd2,$1); 
					//sym=createTempSymbolWithType(st,$3,$3,$1); //This statement gave trouble
					break;
				case MULASSIGN:
					addCode(quadTable,labelpending,MUL,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
				case DIVASSIGN:
					addCode(quadTable,labelpending,DIV,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
				case MODULOASSIGN:
					addCode(quadTable,labelpending,MODULO,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					$$ = $1;
					$$.type = ID;
					break;
				case PLUSASSIGN:
					addCode(quadTable,labelpending,PLUS,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
				case MINUSASSIGN:
					addCode(quadTable,labelpending,MINUS,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					$$ = $1;
					$$.type = ID;
					break;
				case LSHIFTASSIGN:
					addCode(quadTable,labelpending,LSHIFT,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
				case RSIGNEDSHIFTASSIGN:
					addCode(quadTable,labelpending,RSHIFTSIGNED,$1,$3,$1); 
					break;
				case ANDASSIGN:
					addCode(quadTable,labelpending,AND,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
				case ORASSIGN:
					addCode(quadTable,labelpending,OR,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
				case XORASSIGN:
					addCode(quadTable,labelpending,XOR,$1,$3,$1); 
					sym=createTempSymbolWithType(st,$1,$3,$1);
					break;
			}
			$$ = $1;
		}
	;
assignmentOperator: _assign   {assignOpr = ASSIGN;}
|_mulAssign		      {assignOpr = MULASSIGN;}
|_divAssign		      {assignOpr = DIVASSIGN;}
|_moduloAssign                {assignOpr = MODULOASSIGN;}
|_plusAssign                  {assignOpr = PLUSASSIGN;}
|_minusAssign		      {assignOpr = MINUSASSIGN;}
|_lShiftAssign                {assignOpr = LSHIFTASSIGN;}
|_rSignedShiftAssign          {assignOpr = RSIGNEDSHIFTASSIGN;}
|_andAssign		      {assignOpr = ANDASSIGN;}
|_xorAssign		      {assignOpr = XORASSIGN;}
|_orAssign		      {assignOpr = ORASSIGN;}
	;
expression: assignmentExpression
		{
			$$ = $1;
	   	}
|expression     {
			$$ = $1;
	   	}
_comma assignmentExpression
		{
			$$ = $4;
		}
	;
constantExpression: conditionalExpression
		{
			$$ = $1;
		}
	;
statement:	matchedStatement
|unmatchedStatement
	;
ifexprMatchedStatementElse: ifexpr matchedStatement _else 
		{
			
			strcpy(result.name,$1.label2);
			result.type=LABEL;
			opnd1.type = NOP;
			opnd2.type = NOP;
			strcpy(opnd1.name," "); 
			strcpy(opnd2.name," ");
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			strcpy(labelpending,$$.label1);
			strcpy($$.label2,$1.label2);
		}
	;
ifexpr : _if _leftp expression _rightp 
		{
			createLabel($$.label1);
			createLabel($$.label2);
			opnd2.type = CONST;
			opnd2.subtype = INT;
			opnd2.value.iVal = 0;  //false
			result.type = LABEL;
			strcpy(result.name,$$.label1);
			addCode(quadTable,labelpending,IFGO,$3,opnd2,result);
			
		}
	;
matchedStatement:  ifexprMatchedStatementElse  matchedStatement	
		{
			strcpy(labelpending,$1.label2);
		}	
|labeledStatement 
|compoundStatement  
|expressionStatement 
|iterationStatement 
|jumpStatement	
|switchCaseStatement 
	;
unmatchedStatement: ifexpr  statement 
		{
			strcpy(labelpending,$1.label1);
		}
|ifexprMatchedStatementElse  unmatchedStatement 
		{
			strcpy(labelpending,$1.label2); 
		}
	;
switchCaseStatement: _switch 
		{ 
			noCases=0; 
			createLabel($1.falseLabel);
			bstackpush($1.falseLabel);
		}
_leftp expression _rightp 
statement 
		{ 
			//strcpy(labelpending,$1.falseLabel);
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			strcpy(opnd1.name," "); 
			strcpy(opnd2.name," ");

			result.type=LABEL; 
			strcpy(result.name,$1.falseLabel);
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);

			createLabel(labelpending);
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			strcpy(opnd1.name," "); 
			strcpy(opnd2.name," ");
			result.type=NOP; 
			strcpy(result.name," ");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
			caseIdx=0; //printf("no of cases=%d\n",noCases);
			while(caseIdx < noCases-1)
			{
				strcpy(caseExpr,caseExprs[caseIdx]);
				strcpy(caseLabel,caseLabels[caseIdx]);
				caseIdx++;
				opnd1.type=ID; 
				strcpy(opnd1.name,$4.name);
				opnd2.type=ID; 
				strcpy(opnd2.name,caseExpr);
				result.type=LABEL;
				strcpy(result.name,caseLabel);
				addCode(quadTable," ",IFEQGO,opnd1,opnd2,result);
			}

			strcpy(caseExpr,caseExprs[caseIdx]);
			//printf("%s is the caseExpr at caseIdx %d\n",caseExpr,caseIdx);	
			if(strcmp(caseExpr,"default"))  //if no default case exists
			{			
				strcpy(caseLabel,caseLabels[caseIdx]);
				//strcpy(caseExpr,caseExprs[caseIdx]);
				caseIdx++;
				opnd1.type=ID; 
				strcpy(opnd1.name,$4.name);
				opnd2.type=ID; 
				strcpy(opnd2.name,caseExpr);
				result.type=LABEL;
				strcpy(result.name,caseLabel);
				addCode(quadTable," ",IFEQGO,opnd1,opnd2,result);
			}
			else
			{
				strcpy(caseLabel,caseLabels[caseIdx]);
				caseIdx++;
				opnd1.type=NOP; 
				opnd2.type=NOP; 
				strcpy(opnd1.name," "); 
				strcpy(opnd2.name," ");
				result.type=LABEL;
				strcpy(result.name,caseLabel);
				addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			}

			strcpy(labelpending,$1.falseLabel);
			opnd1.type=NOP;
			strcpy(opnd1.name," ");  
			opnd2.type=NOP; 
			strcpy(opnd2.name," ");  
			result.type=NOP; 
			strcpy(result.name," ");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result); 
			bstackpop();
			noCases=0;
		}
	;
labeledStatement: identifier _colon 
		{
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			strcpy(opnd1.name," "); 
			strcpy(opnd2.name," ");
			result.type=NOP; 
			strcpy(result.name," ");
			strcpy(labelpending,$1.name);
			strcat(labelpending,":");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
		}
statement 
|_case constantExpression _colon 
		{
			strcpy(caseExprs[noCases],$2.name);
			createLabel(tempLabel);
			strcpy(caseLabels[noCases],tempLabel);
			noCases++;
			strcpy(labelpending,tempLabel);
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			strcpy(opnd1.name," "); 
			strcpy(opnd2.name," ");
			result.type=NOP; 
			strcpy(result.name," ");
			strcpy(labelpending,tempLabel);
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
		}
statement
|_default  _colon 
		{
			strcpy(caseExprs[noCases],"default");
			createLabel(tempLabel);
			strcpy(caseLabels[noCases],tempLabel);
			noCases++;
			//strcpy(labelpending,tempLabel);
			opnd1.type=NOP;  
			opnd2.type=NOP;
			strcpy(opnd1.name," "); 
			strcpy(opnd2.name," ");
			result.type=NOP; 
			strcpy(result.name," ");
			strcpy(labelpending,tempLabel);
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
		}
statement
	;
compoundStatement: _leftb 
		{ 
			fst = (ST*)malloc(sizeof(ST));
			if(fst==NULL) 
			{
				printf("Error: Memory allocation Problem for Symbol Table..Existing\n");
				exit(-1);
			}
			fst->prevst=prevst;
			strcpy(fst->funcName,sym.name);
			sym.st = fst;
			addSymbolHash(st,sym);
			prevst=st;
			st=fst;
			initHash(st,HASHSIZE);
			fst = NULL;
 		}
blockItemListopt _rightb 
		{ 	//dispSymbolTableHash(st);
			st = st->prevst;			 
		} 
	;
blockItemListopt:	| blockItemList 
	;
blockItemList: blockItem 
|blockItemList blockItem
	;
blockItem: declaration 
|statement 
	;
expressionStatement: expressionopt _semicolon
	;
expressionopt:	|expression
	;
iterationStatement: _while 
		{ 
			createLabel($1.trueLabel); 
			createLabel($1.falseLabel);
			strcpy(labelpending,$1.trueLabel);
			cstackpush($1.trueLabel);
			bstackpush($1.falseLabel);
		}
_leftp expression 
		{
				      	
			opnd2.type = CONST;
			opnd2.subtype = INT;
			opnd2.value.iVal = 0;
			createTemp(result.name);
			result.type = LABEL;
			strcpy(result.name,$1.falseLabel);
			addCode(quadTable,labelpending,IFGO,$4,opnd2,result);
		}
_rightp statement 
		{
			opnd1.type = NOP;
			opnd2.type = NOP;
			result.type = LABEL;
			strcpy(result.name,$1.trueLabel);
			addCode(quadTable," ",GOTO,opnd1, opnd2,result);
                	strcpy(labelpending,$1.falseLabel);
			opnd1.type=NOP;
			opnd2.type=NOP;
			result.type=NOP;
			strcpy(result.name," ");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
			cstackpop();
			bstackpop();
		}
|_do 				
		{
			createLabel($1.trueLabel);
			createLabel($1.falseLabel);
			cstackpush($1.trueLabel);
			bstackpush($1.falseLabel);
			strcpy(labelpending, $1.trueLabel);
		}
statement _while _leftp expression 
		{
					
			opnd2.type = CONST;
			opnd2.subtype = INT;
			opnd2.value.iVal = 0;
			createTemp(result.name);
			//result.type = CONST;
			result.type = LABEL;
			//result.datatype = FALSE;
			strcpy(result.name,$1.falseLabel);
			addCode(quadTable,labelpending,IFGO,$6,opnd2,result);
			opnd1.type = NOP;
			opnd2.type = NOP;
			createTemp(result.name);
			result.type = LABEL;
			strcpy(result.name,$1.trueLabel);
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			strcpy(labelpending,$1.falseLabel);
			opnd1.type=NOP;
			opnd2.type=NOP;
			result.type=NOP;
			strcpy(result.name," ");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
			cstackpop();
			bstackpop();
		}
_rightp _semicolon
|_for  _leftp 			
		{
			createLabel($1.cond2Label);
			createLabel($1.cond3Label);
			createLabel($1.cond2TestLabel);
			createLabel($1.nextStmtLabel);
			cstackpush($1.cond2Label);
			bstackpush($1.nextStmtLabel);
			
		}  
expressionopt _semicolon 
		{ 
			strcpy(labelpending,$1.cond2Label);
		}
expressionopt _semicolon 
		{
			result.type=LABEL;
			strcpy(result.name,$1.cond2TestLabel);
			opnd1.type=NOP;
			opnd2.type=NOP;
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			strcpy(labelpending,$1.cond3Label);
		} 
expressionopt _rightp 
		{
			result.type=LABEL;
			strcpy(result.name,$1.cond2Label);
			opnd1.type=NOP;
			opnd2.type=NOP;
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			strcpy(labelpending,$1.cond2TestLabel);
			opnd2.type = CONST;
			opnd2.subtype = INT;
			opnd2.value.iVal = 0;
			result.type=LABEL;
			strcpy(result.name,$1.nextStmtLabel);
     			addCode(quadTable,labelpending,IFGO,$7,opnd2,result);
		} 

statement 		
		{
			opnd1.type = NOP;
			opnd2.type = NOP;
			result.type=LABEL;
			strcpy(result.name,$1.cond3Label);
			addCode(quadTable," ",GOTO,opnd1,opnd2,result); 
			strcpy(labelpending,$1.nextStmtLabel);
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			result.type=NOP; 
			strcpy(result.name," ");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
			cstackpop();
			bstackpop();
		}
|_for _leftp 
		{
			createLabel($1.cond2Label);
			createLabel($1.cond3Label);
			createLabel($1.cond2TestLabel);
			createLabel($1.nextStmtLabel);
	     	}  
declaration expressionopt _semicolon 
		{
			result.type=LABEL;
			strcpy(result.name,$1.cond2TestLabel);
			opnd1.type=NOP;
			opnd2.type=NOP;
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			//addCode(quadTable," ",GOTO," "," ",$1.cond2TestLabel);
			strcpy(labelpending,$1.cond3Label);
		} 
expressionopt _rightp 
		{
			result.type=LABEL;
			strcpy(result.name,$1.cond2Label);
			opnd1.type=NOP;
			opnd2.type=NOP;
			addCode(quadTable," ",GOTO,opnd1,opnd2,result);
			strcpy(labelpending,$1.cond2TestLabel);
			opnd2.type = CONST;
			opnd2.subtype = INT;
			opnd2.value.iVal = 0;
			result.type=LABEL;
			strcpy(result.name,$1.nextStmtLabel);
     			addCode(quadTable,labelpending,IFGO,$7,opnd2,result);
		} 
statement 
		{
			opnd1.type = NOP;
			opnd2.type = NOP;
			result.type=LABEL;
			strcpy(result.name,$1.cond3Label);
			addCode(quadTable," ",GOTO,opnd1,opnd2,result); 
			strcpy(labelpending,$1.nextStmtLabel);
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			result.type=NOP; 
			strcpy(result.name," ");
			addCode(quadTable,labelpending,NOP,opnd1,opnd2,result); 
		}
	;
jumpStatement: _goto identifier _semicolon 
		{
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			result.type=LABEL; 
			strcpy(result.name,$2.name);
			addCode(quadTable,labelpending,GOTO,opnd1,opnd2,result);
		}
|_continue _semicolon		
		{
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			result.type=LABEL; 
			if(cstackTop != -1) 
			{
				strcpy(result.name,cstack[cstackTop]);
				addCode(quadTable,labelpending,GOTO,opnd1,opnd2,result);
			}
		}
|_break _semicolon		
		{
			opnd1.type=NOP;  
			opnd2.type=NOP; 
			result.type=LABEL;
			if(bstackTop != -1)
			{
				strcpy(result.name,bstack[bstackTop]); 
				addCode(quadTable,labelpending,GOTO,opnd1,opnd2,result);
			}
		}
|_return expressionopt _semicolon
	;
identifier:	_id  
		{
			strcpy($$.name,$1.name);
		}
	;
%%

int yyerror(char *errmsg)
{
        printf("%s: Error has occurred in parsing Program\n",errmsg);
        exit(-1);
}
	