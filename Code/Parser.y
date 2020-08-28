	%token PLUS
	%token MINUS
	%token MULTIPLY
	%token DIVIDE
	%token ASSIGN
	%token AND
	%token OR
	%token NOT
	%token INC;
    %token DEC;
	%token PLUSEQUAL
	%token MINUSEQUAL
	%token MULTIPLYEQUAL
	%token DIVIDEEQUAL
	%token OBRACE 
	%token CBRACE
	%token OBRACKET  
	%token CBRACKET
	%token SEMICOLON  
	%token PRINT
	%token BOOL
	%token INT
	%token FLOAT
	%token CHAR
	%token STRING
	%token CONST
	%token FALSE
	%token TRUE
	%token GREATERTHAN
	%token LESSTHAN
	%token GREATERTHANOREQUAL
	%token LESSTHANOREQUAL
	%token EQUALEQUAL
	%token NOTEQUAL
	%token WHILE
	%token FOR
	%token IF
	%token ELSE
	
// to set which operations should be done first
	%left ASSIGN
	%left GREATERTHAN LESSTHAN
	%left GREATERTHANOREQUAL LESSTHANOREQUAL
	%left EQUALEQUAL NOTEQUAL
	%left AND OR NOT
	%left PLUS MINUS 
	%left DIVIDE MULTIPLY
	%union{
    int IntgerValue;                 // INTEGERNUMBER
	float FloatValue;               // float
    char * StringValue;              // string or text
	int* INTPOINTER;
	struct TypeAndValue * TYPE_VALUE;
	};
	%token <IntgerValue> INTEGERNUMBER 
	%token <FloatValue> FLOATNUMBER 
	%token <StringValue> TEXT CHARACTER Var_Name
	%type <IntgerValue> type   
	%type <INTPOINTER> Instruction  increments ForLoopEquation blockScope InstructionList scopeOpen scopeClose 
	%type <TYPE_VALUE> equations expression Data BoolEquation
%{ 	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include <string.h>	
	#include"SymbolTable.h"

    int yyerror(char *);
	int yylex(void);
	int yylineno;
	
	
	
	
	
	void Create_Variable(int type , char*rName,int rID,int ScopeNum);			// -- create a variable when it is declared
	void  Set_Initialized(char*rName,int ScopeNum);						//--  set variable to be Initilized if it is declared. 
	void Set_Used(char*rName,int ScopeNum );					    //--  set variable to be used if it is declared 
	bool checktype(int LeftType,int RightType);	            //--  Check Left and Right hand side in Assigment operation;
	void Error(char *Message, char *Var);							//--  A Function to Terminate the Program and Report an Error
	char* VariableTypes[10] = { "int", "Float", "Char", "String", "Bool", "ConstInt", "ConstFloat", "ConstChar", "ConstString", "ConstBool" };
	bool TempIsUsed=false;                                    // to check which temp to write in  
	int Counter=0;                                       // to get the temp number
	char*TempArr[4]={"Temp1","Temp2","Temp3","Temp4"};      // temp register used in the assembly code
	int count=0;
	char * AdjustErrorMessage(char* str1,char*str2);
	int InstructionNumber=0;
	int SCOPE_Number=0;                //to see each variable scope which it is defined in 
	
	

	%}
	
	
%%














Program :      Program Instruction  
		|
		;
		
Instruction:   type Var_Name SEMICOLON	                 				{
																				
																				Create_Variable($1,$2,count++,SCOPE_Number);
																				printf("Declaration without Assigment\n");
																				Set_Instruction_Arguments(0," "," ",$2,InstructionNumber++);
																			}
																			
		| type Var_Name ASSIGN expression	SEMICOLON	      				{
																			
																			Create_Variable($1,$2,count++,SCOPE_Number);
																			if(checktype(GetVariableType($2),$4->Type))
																			{
																			Set_Initialized($2,SCOPE_Number);
																			Set_Instruction_Arguments(0," "," ",$2,InstructionNumber++);
																				if(TempIsUsed)
																					Set_Instruction_Arguments(1,TempArr[Counter-1]," ",$2,InstructionNumber++);
																					else Set_Instruction_Arguments(1,$4->Value," ",$2,InstructionNumber++);
																			printf("Declaration and Assignment\n");
																					Counter=0;
																				TempIsUsed=false;
																			}
																			else
																				{
																					char*str1=AdjustErrorMessage($2," of Type ");
																					char* str2=AdjustErrorMessage(str1,VariableTypes[GetVariableType($2)]);
												
																				Error("Error: Type mismatch ",str2);
																				}
																			}
		| CONST type Var_Name ASSIGN expression SEMICOLON   				{
																			
																				Create_Variable($2+5,$3,count++,SCOPE_Number);
																			if(checktype(GetVariableType($3),$5->Type))
																			{
																			
																				
																				Set_Instruction_Arguments(0," "," ",$3,InstructionNumber++);
																				if(TempIsUsed)
																					Set_Instruction_Arguments(1,TempArr[Counter-1]," ",$3,InstructionNumber++);
																					else Set_Instruction_Arguments(1,$5->Value," ",$3,InstructionNumber++);
																					printf("Constant Declaration and Assignment\n");
																					Counter=0;
																					TempIsUsed=false;
																			}
																			else
																				{
																					char*str1=AdjustErrorMessage($3," of Type ");
																					char* str2=AdjustErrorMessage(str1,VariableTypes[GetVariableType($3)]);
																			
																				Error("Error: Type mismatch ",str2);
																				}
																			;}

		| Var_Name ASSIGN expression SEMICOLON	          				{
																				
																		
																			if(GetVariableType($1)==$3->Type || (GetVariableType($1)-5)==$3->Type)
																				{
																				
																					Set_Initialized($1,SCOPE_Number);
																					printf("Assignment\n");
																					if(TempIsUsed)
																					Set_Instruction_Arguments(1,TempArr[Counter-1]," ",$1,InstructionNumber++);
																					else Set_Instruction_Arguments(1,$3->Value," ",$1,InstructionNumber++);
																					Counter=0;
																					TempIsUsed=false;
																				}
																			else 
																				{
																					if(GetVariableType($1)==-1)
																					{
																					char*str1=AdjustErrorMessage($1," Has No Declread Type ");
																					Error("",str1);
																					}
																					char*str1=AdjustErrorMessage($1," of Type");
												
																					char* str2=AdjustErrorMessage(str1,VariableTypes[GetVariableType($1)]);
																			
																				Error("Error: Type mismatch ",str2);
																				}
																			}

		
        | PRINT expression 	SEMICOLON	                        				{
																				 printf("Print\n");
																				 Set_Instruction_Arguments(21,"Print","",$2->Value,InstructionNumber++);
																				}
		
		| IF OBRACKET ifexpression  CBRACKET  blockScope  			{
																	printf("If statement\n");
																	Set_Instruction_Arguments(19,"IF ","Close_IF","",InstructionNumber++);
																	}

		| IF OBRACKET ifexpression  CBRACKET blockScope ELSE  else	{
																	printf("If Else statement\n");
																	Set_Instruction_Arguments(22,"IF ","Close_ELSE","",InstructionNumber++);
																	}
																	
		| WHILE OBRACKET whileexpression CBRACKET  Instruction		{
																	char c[3] = {};gcvt(SCOPE_Number,6,c);
																	Set_Instruction_Arguments(23,c,"WhileBegin","WhileEnd",InstructionNumber++);
																	printf("While loop\n");
																	}


		| FOR OBRACKET INT  ForLoopEquation  SEMICOLON forexpression
		  increments CBRACKET
		  blockScope											  			{
																			printf("For loop\n");
																			Set_Instruction_Arguments(24,"","ForLoopBegin","ForLoopEnd",InstructionNumber++);
																			} 

		| blockScope															{
																				}
		|increments SEMICOLON													{
																				}	
		
		;

equations:   
		 INTEGERNUMBER		                       {
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=0;
												char c[3] = {}; 
												sprintf(c,"%d",$1);
												$$->Value=c;
											   }
		| FLOATNUMBER                     	   {
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=1;												
												char c[3] = {};
												sprintf(c,"%f",$1);
												$$->Value=c;
											   }									   
		| Var_Name                           {$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));$$->Type=GetVariableType($1);$$->Value=$1;Set_Used($1,SCOPE_Number);}
		| equations PLUS equations          {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[Counter];// store  the Result in TEMP 
													Set_Instruction_Arguments(2,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++);//Generate ADD Quadrable 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													Error("Conflict dataTypes in Addition \n "," ");
												}
		| equations MINUS equations        {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[Counter];// store  the Result in TEMP 
													Set_Instruction_Arguments(3,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													Error("Conflict dataTypes in Subtraction \n "," ");
												}
		| equations MULTIPLY equations     {
												if($1->Type==$3->Type)
												{
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[Counter];// store  the Result in TEMP 
													Set_Instruction_Arguments(4,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
													TempIsUsed=true;//Tell the Assigment test to Assign the last TEMP 
												
												}
												else 
													Error("Conflict dataTypes in Multiplication \n "," ");
												}
		| equations  DIVIDE	equations    
												{
												if($1->Type==$3->Type)
												{
													if(!($3->Value))Error("Error Dividing by Zero  \n "," ");
													$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));// Creating a new instance
													$$->Type=$1->Type;// the result has the same type 
													$$->Value=TempArr[Counter];// store  the Result in TEMP 
													Set_Instruction_Arguments(5,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
													TempIsUsed=true; 
												
												}
												else 
													Error("Conflict dataTypes in Division \n "," ");
												}
												
		| Var_Name INC                       {$$->Type=GetVariableType($1);$$->Value=$1;Set_Used($1,SCOPE_Number);Set_Instruction_Arguments(15,"INC","INC",$1,InstructionNumber++);}
		| Var_Name DEC                       {$$->Type=GetVariableType($1);$$->Value=$1;Set_Used($1,SCOPE_Number);Set_Instruction_Arguments(16,"DEC","DEC",$1,InstructionNumber++);}
		| OBRACKET equations CBRACKET       {$$=$2;}
		;


type:   INT {$$=0;}
		| FLOAT {$$=1;}
		| CHAR  {$$=2;}
		| STRING{$$=3;}
		| BOOL	{$$=4;}
	;
	
	
Data:	equations                   {$$=$1;}
		| FALSE 						{
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=4;	$$->Value=strdup("FALSE");						
										}
	    | TRUE							{
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=4;	$$->Value=strdup("TRUE");				
										}
		| CHARACTER 					{	
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=2;	$$->Value=strdup($1);			
										}
		| TEXT 							{	
												$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
												$$->Type=3;	$$->Value=strdup($1);															
										}
		;

expression:	Data                  {{$$=$1;}}
		| BoolEquation            {{$$=$1; }} ;
		 		   		
	
ForLoopEquation :Var_Name ASSIGN INTEGERNUMBER   {Create_Variable(0,$1 ,count++,SCOPE_Number+1);Set_Initialized($1,SCOPE_Number);char c[3] = {};sprintf(c,"%d",$3);Set_Instruction_Arguments(1,c," ",$1,InstructionNumber++);}; 				
forexpression:  expression SEMICOLON       {char c[3] = {};sprintf(c,"%f",SCOPE_Number);Set_Instruction_Arguments(17,c,$1->Value,"OpenForLoop",InstructionNumber++);}
whileexpression:  expression               {char c[3] = {};sprintf(c,"%f",SCOPE_Number);Set_Instruction_Arguments(18,c,$1->Value,"WhileBegin",InstructionNumber++);}
blockScope:	 OBRACE scopeOpen InstructionList CBRACE scopeClose	{printf("new Scope\n");}
			| OBRACE scopeOpen CBRACE scopeClose												{
																								}
		;


scopeOpen :{
			SCOPE_Number++;}
scopeClose :{
				Kill_Variables(SCOPE_Number);
				SCOPE_Number--;
			}		

InstructionList:  Instruction 				{$$=$1;} 
        | InstructionList Instruction 		{}




increments: Var_Name  INC            			 	 {
													  Set_Used($1,SCOPE_Number);
													  Set_Instruction_Arguments(15,"INC","INC",$1,InstructionNumber++);}
													  
		| Var_Name DEC               			     {
														Set_Used($1,SCOPE_Number);
														Set_Instruction_Arguments(16,"DEC","DEC",$1,InstructionNumber++);
													 }
		;

		 
BoolEquation: expression AND expression          {
										
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(6,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++);
															TempIsUsed=true;//set the temp register to true  
														}
															
			| expression OR expression             	{
													
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(7,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
															TempIsUsed=true;//set the temp register to true  
														;
														}
			| NOT expression                        {
														
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$2->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(8,$2->Value," ",TempArr[Counter++],InstructionNumber++); 
															TempIsUsed=true;//set the temp register to true  
														
														}
			| Data GREATERTHAN Data         {
														if($1->Type!=$3->Type) 
															Error("Conflict dataTypes in GREATERTHAN Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(9,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
															TempIsUsed=true;//set the temp register to true 
														 }
														}
			| Data LESSTHAN Data            {
														if($1->Type!=$3->Type) 
															Error("Conflict dataTypes in LESSTHAN Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(10,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
															TempIsUsed=true;//set the temp register to true  
														; }
														}
			| Data GREATERTHANOREQUAL Data  {
														if($1->Type!=$3->Type) 
															Error("Conflict dataTypes in GREATERTHANOREQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(11,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
															TempIsUsed=true;//set the temp register to true  
														; }
														}
			| Data LESSTHANOREQUAL Data     {
														if($1->Type!=$3->Type) 
															Error("Conflict dataTypes in LESSTHANOREQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(12,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++);
															TempIsUsed=true;//set the temp register to true  
														; }
														}
			| Data NOTEQUAL Data              {
														if($1->Type!=$3->Type) 
															Error("Conflict dataTypes in NOTEQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(13,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++);
															TempIsUsed=true;//set the temp register to true 
														; }
														}
			| Data EQUALEQUAL Data            {
														if($1->Type!=$3->Type) 
															Error("Conflict dataTypes in EQUALEQUAL Operation \n "," "); 
														{
															$$=(struct TypeAndValue*) malloc(sizeof(struct TypeAndValue));
															$$->Type=$1->Type;// the result has the same type 
															$$->Value=TempArr[Counter];// store  the Result in TEMP 
															Set_Instruction_Arguments(14,$1->Value,$3->Value,TempArr[Counter++],InstructionNumber++); 
															TempIsUsed=true;//set the temp register to true  
														; }
														}
			| OBRACKET BoolEquation CBRACKET   {$$=$2;}
			;
			




ifexpression:  expression                     {Set_Instruction_Arguments(19,"IF ","OpenIF","",InstructionNumber++);}
else:  blockScope                            {Set_Instruction_Arguments(20,"else","n","",InstructionNumber++);}






		   
%% 



FILE * outputfile;
FILE * inputfile;
FILE *SymbolTableFile;

void Create_Variable(int type , char*rName,int rID,int ScopeNum)
{
	if(Check_Variable_Declared(rName))
	Error("Already Declared Variable with Name ",rName);
	else
	{
		bool isConstant=(type>4)?true:false;
		Variable_Properties* rSymbol=SetVariableProperties(type,0,false,rName,!isConstant,ScopeNum);
		if(isConstant)
		{
			rSymbol->Initilzation=true;                // constant variables should be initialized when declared
			Insert_Variable(rID,rSymbol);
			printf("Constant Variable is created with Name %s \n",rName);	
		}
		else 
		{
			Insert_Variable(rID,rSymbol);
			printf(" Variable is created with Name %s \n",rName);
		}
	}
}

bool checktype(int LeftType,int RightType)
{
    if( (LeftType==RightType) || (LeftType-5 ==RightType))
	{
	return true;
	}
	else {
	return false;
	}
	
}

void Set_Initialized(char*rName,int ScopeNum)
{
	Variable_Node * rSymbol=GetVariableID(rName, ScopeNum);
	if(!rSymbol)
	{
		Error("Not Declared in This Scope Variable with Name \n ",rName);
	}
	else
	{
		if(!rSymbol->DATA->isConstant)
			Error("Can't change a Constant Variable with Name \n ",rName);
		else
			rSymbol->DATA->Initilzation=true;
	}
}

void Set_Used(char*rName,int ScopeNum)
{
	Variable_Node * rSymbol=GetVariableID(rName, ScopeNum);
	if(!rSymbol)
	Error("Not Declared in This Scope Variable with Name \n ",rName);
	else
	{
		rSymbol->DATA->Used=true;
	}
}

void Error(char *Message, char *Var)
{
	fclose(inputfile);
	inputfile = fopen("output.txt","w");
	fprintf(inputfile, "Syntax Error\n");
 	fprintf(inputfile, "line number: %d %s : %s\n", yylineno,Message,Var);
	printf("line number: %d %s : %s\n", yylineno,Message,Var);
	fclose(SymbolTableFile);
	SymbolTableFile = fopen("Variable Types.txt","w");
	fprintf(SymbolTableFile, "Syntax Error was Found\n");
 	fprintf(SymbolTableFile, "line number: %d %s : %s\n", yylineno,Message,Var);
 	exit(0);
}



 int yyerror(char *s)
 {  
	int lineno=++yylineno;
	fprintf(stderr, "line number : %d %s\n", lineno,s);
	return 0; 
 }
 
 char * AdjustErrorMessage(char* str1,char*str2)
 {  
      char * str3 = (char *) malloc(1 + strlen(str1)+ strlen(str2) );
      strcpy(str3, str1);	  
      strcat(str3, str2);
	return str3;
 
 }
 int main(void) {
	
	
	inputfile = fopen("input.txt", "r");
	outputfile=fopen("output.txt","w");
	FILE *mCode=fopen("AssemblyCode.txt","w");
	SymbolTableFile=fopen("Variable Types.txt","w");
	if(!yyparse()) {
		printf("\nParsing complete\n");
		PrintSymbolTable(SymbolTableFile);
		Instruction_Linked_List*R=getTOP();
		GetAssembley(R,mCode);
		
		fprintf(outputfile,"Successful");
	}
	else {
		printf("\nParsing failed\n %d",yylineno);
		return 0;
	}
	
	fclose(inputfile);
	fclose(outputfile);
    return 0;
}