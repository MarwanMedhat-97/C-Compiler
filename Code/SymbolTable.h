#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<string.h> 


typedef struct Register
{
	char* reg_num;
	char* value;
	int used;
}Register;
typedef struct Instruction
{
	int OpCode;	
	char*Arg1;
	char*Arg2;
	char*Result;

}Instruction;
typedef struct Instruction_Linked_List {
	struct Instruction * DATA;
	int ID;
	struct Instruction_Linked_List *Next;
} Instruction_Linked_List;
typedef struct TypeAndValue {
	int Type;
	char*  Value;
} TypeAndValue;
typedef struct Variable_Properties
{
	char * VariableName;            //variable Name
	char * Value;					//variable Value
	int Type;						//Variable type
	bool Initilzation;				//variable initialized or not
	bool Used;						//variable used or not 
	int ScopeNumber;				//the scope number that the variable is decleared in
	bool isConstant;				//represent var constant or not  
}Variable_Properties;
typedef struct Variable_Node {
	struct Variable_Properties * DATA;
	int ID;						
	struct Variable_Node *Next;
} Variable_Node;


struct Variable_Properties* SetVariableProperties(int rType, int rValue, bool rUsed,char* Identifyier,bool isConstant,int ScopeNum);
void Insert_Variable(int ID, struct Variable_Properties* data);
bool Check_Variable_Declared(char * ID);                                          //check weather identifuer is defined before or not
Variable_Node * GetVariableID(char * VarName, int SCOPE);                // to check if the variable is initialized or used before or not
int GetVariableType(char*rID);
void setFuncArg(int ArgCount, int*ArgTypes, Variable_Properties *rD);
int checkArgType(int ArgCount, int*ArgTypes, char *rD, int Scope);
void Kill_Variables(int Brace);
void Insert_Instruction(Instruction*rD, int ID);
void Set_Instruction_Arguments(int Op, char* Arg1, char* Arg2, char*Result, int rID);
Instruction_Linked_List*getTOP();
void GetAssembley(Instruction_Linked_List* head,FILE *f);
void PrintSymbolTable(FILE*f);