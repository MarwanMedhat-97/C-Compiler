#include"SymbolTable.h"

Register reg[8];
char* var_types[10] = { "Integer", "Float", "Char", "String", "Bool", "ConstIntger", "ConstFloat", "ConstChar", "ConstString", "ConstBool" };
struct Variable_Node * ListTop = NULL;
Instruction_Linked_List*TopPtr = NULL;



struct Variable_Properties* SetVariableProperties(int rType, int rValue, bool rUsed,char* Identifyier,bool isConstant,int ScopeNum)
{
	struct Variable_Properties *data = (struct Variable_Properties*) malloc(sizeof(struct Variable_Properties));
	data->Type = rType;
	data->Initilzation = rValue;
	data->Used = rUsed;
	data->VariableName = Identifyier;
	data->isConstant=isConstant; 
	data->ScopeNumber = ScopeNum;
	

	return data;
}
void Insert_Variable(int index, struct Variable_Properties *data) {
	 
	struct Variable_Node *mySymbolNode = (struct Variable_Node*) malloc(sizeof(struct Variable_Node));
	mySymbolNode->ID = index;
	mySymbolNode->DATA = data;
	mySymbolNode->Next = ListTop;
	ListTop = mySymbolNode;
}

Variable_Node * GetVariableID(char * VarName, int SCOPE)
{
	Variable_Node * temp = ListTop;

	while (temp)
	{
		if ((strcmp(VarName, temp->DATA->VariableName)==0 ) && (temp->DATA->ScopeNumber !=-1 ) )
		{
			return temp;
		}

		temp = temp->Next;
	}

	return NULL;
}
bool Check_Variable_Declared(char * ID)
{
	Variable_Node * temp = ListTop;

	while (temp)
	{
		if (strcmp(ID, temp->DATA->VariableName) == 0)
		{
			return true;
		}

		temp = temp->Next;
	}

	return-false;

}

int GetVariableType(char * rID)
{
	Variable_Node * temp = ListTop;
	while (temp)
	{
		if (strcmp(rID, temp->DATA->VariableName) == 0)
		{
			return temp->DATA->Type;
		}

		temp = temp->Next;
	}
	return -1;

}

void Kill_Variables(int Brace)
{
	Variable_Node * temp = ListTop;
	while (temp)
	{
		if  (temp->DATA->ScopeNumber == Brace)
		{
			temp->DATA->ScopeNumber = -1;
		}

		temp = temp->Next;
	}
}




//-----------------------------------------------------------------------------------------------------



void Set_Instruction_Arguments(int Op, char* Arg1, char* Arg2,char*Result,int rID)
{
	struct Instruction *data = (struct Instruction*) malloc(sizeof(struct Instruction));
	data->OpCode = Op;
	data->Arg1 = Arg1;
	data->Arg2 = Arg2;
	data->Result = Result;
	Insert_Instruction(data, rID); 
	return ;
}
void Insert_Instruction(Instruction*rD, int ID)
{
	if (!TopPtr) // if Instruction list is empty
	{
	struct Instruction_Linked_List *mySymbolNode = (struct Instruction_Linked_List*) malloc(sizeof(struct Instruction_Linked_List));
	TopPtr = mySymbolNode;
	mySymbolNode->ID = ID;
	mySymbolNode->DATA = rD;
	TopPtr->Next = NULL;
	return;
	}
	struct Instruction_Linked_List *temp = TopPtr;
	while (temp->Next)   // get the end of the list to insert the instruction in it
	{
		temp = temp->Next;              
	}
	
	struct Instruction_Linked_List *mySymbolNode = (struct Instruction_Linked_List*) malloc(sizeof(struct Instruction_Linked_List));
	mySymbolNode->ID = ID;
	mySymbolNode->DATA = rD;
	mySymbolNode->Next = NULL;
	temp->Next = mySymbolNode; 
}
Instruction_Linked_List*getTOP()
{
	return TopPtr;
}



Register Get_Min_Free_Reg()
{
	Register min = reg[0];
	if (min.value == "0")
	{
		return min;
	}
	else
	{
		int i;
		for ( i = 0; i<7; i++)
		{
			if (reg[i].value == "0")
			{
				return reg[i];
			}
			else if (reg[i].used < min.used)
			{
				min = reg[i];
			}
		}
		return min;
	}
}
void Set_Reg_Value(Register x)
{
	int i;
	for ( i = 0; i<7; i++)
	{
		if (reg[i].reg_num == x.reg_num)
		{
			reg[i].used = x.used;
			reg[i].value = x.value;
		}
	}
}



void GetAssembley(Instruction_Linked_List* head,FILE *f)
{
	Instruction_Linked_List*ptr = head;
	reg[0].reg_num="R0";
	reg[1].reg_num="R1";
	reg[2].reg_num="R2";
	reg[3].reg_num="R3";
	reg[4].reg_num="R4";
	reg[5].reg_num="R5";
	reg[6].reg_num="R6";
	reg[7].reg_num="R7";
	Register free;
	Register Temp;
	while (ptr != NULL)
	{
		if(ptr->DATA->OpCode==0)  // DECLARE
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", ptr->DATA->Result,free.reg_num);
			free.used++;
			free.value = ptr->DATA->Result;
			Set_Reg_Value(free);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==1) // ASSIGN
		{
			free = Get_Min_Free_Reg();
			if (ptr->DATA->Arg1 != " ") {
				fprintf(f, "MOV %s , %s \n", free.reg_num,ptr->DATA->Arg1);
				fprintf(f, "MOV %s , %s \n", ptr->DATA->Result, free.reg_num);
			}
			else if (ptr->DATA->Arg2 != " ") {
				fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg2);
				fprintf(f, "MOV %s , %s \n", ptr->DATA->Result, free.reg_num);
			}
			free.used++;
			free.value = ptr->DATA->Result;
			Set_Reg_Value(free);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==2)  // ADD
		{
			free = Get_Min_Free_Reg();
			Temp = free;
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg1);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg2);
			free.used++;
			free.value = ptr->DATA->Arg2;
			Set_Reg_Value(free);
			fprintf(f, "ADD %s , %s , %s\n", ptr->DATA->Result,Temp.reg_num, free.reg_num);                
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==3) // SUB
		{
			free = Get_Min_Free_Reg();
			Temp = free;
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg1);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg2);
			free.used++;
			free.value = ptr->DATA->Arg2;
			Set_Reg_Value(free);
			fprintf(f, "SUB %s , %s , %s\n", ptr->DATA->Result,Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==4) // MUL
		{
			free = Get_Min_Free_Reg();
			Temp = free;
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg1);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg2);
			free.used++;
			free.value = ptr->DATA->Arg2;
			Set_Reg_Value(free);
			fprintf(f, "MUL %s , %s , %s\n", ptr->DATA->Result,Temp.reg_num, free.reg_num);// add new REGISTER ! 
			ptr = ptr->Next;
		}	
		else if(ptr->DATA->OpCode==5) //DIV
		{
			fprintf(f, "MOV %s , %s \n", "R0", ptr->DATA->Arg1);
			free = Get_Min_Free_Reg();
			if(free.reg_num == "R0")
				free.reg_num = "R7";
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg2);
			fprintf(f, "DIV %s \n", free.reg_num);
			fprintf(f, "MOV %s , %s \n", ptr->DATA->Result, "R0");
			ptr = ptr->Next;
		}		
		else if(ptr->DATA->OpCode==6) // AND
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "AND %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==7) // OR
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "OR %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==8) //NOT
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			fprintf(f, "NOT %s \n", free.reg_num);
			fprintf(f, "MOV %s , %s \n", ptr->DATA->Result, free.reg_num);
			free.used++;
			free.value = ptr->DATA->Arg2;
			ptr = ptr->Next;
			Set_Reg_Value(free);
		}
		else if(ptr->DATA->OpCode==9) // Greater than
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "CMPG %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==10) // less than
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "CMPL %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==11) // greater than or equal
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "CMPGEQ %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==12)  // less than or equal
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "CMPLEQ %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==13)  // Not equal
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "CMPNEQ %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==14)  // equal equal
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Arg1);
			free.used++;
			free.value = ptr->DATA->Arg1;
			Set_Reg_Value(free);
			Temp = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", Temp.reg_num, ptr->DATA->Arg2);
			Temp.used++;
			Temp.value = ptr->DATA->Arg1;
			Set_Reg_Value(Temp);
			fprintf(f, "CMPEQ %s, %s , %s \n", ptr->DATA->Result, Temp.reg_num, free.reg_num);
			ptr = ptr->Next;
		}
		
		else if(ptr->DATA->OpCode==15) // INC
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Result);
			fprintf(f, "INC %s \n", free.reg_num);
			fprintf(f, "MOV %s , %s \n", ptr->DATA->Result,free.reg_num);
			free.used++;
			free.value = ptr->DATA->Arg2;
			Set_Reg_Value(free);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==16) // DEC
		{
			free = Get_Min_Free_Reg();
			fprintf(f, "MOV %s , %s \n", free.reg_num, ptr->DATA->Result);
			fprintf(f, "DEC %s \n", free.reg_num);
			fprintf(f, "MOV %s , %s \n", ptr->DATA->Result,free.reg_num);
			free.used++;
			free.value = ptr->DATA->Arg2;
			Set_Reg_Value(free);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==17) // For loop begin
		{
			fprintf(f, "%s : \n", ptr->DATA->Result);
			fprintf(f, "JZ %s \n","ForLoopEnd");         //check and jump to loop end at each iteration begining 
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==18)  // while loop begin
		{
			fprintf(f, "%s : \n", ptr->DATA->Result);
			fprintf(f, "JZ %s \n","WhileEnd");          //check and jump to loop end at each iteration begining 
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==19)  // If condition
		{
			fprintf(f, "%s \n", ptr->DATA->Arg2);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==20)   //  else 
		{
			fprintf(f, "%s \n", "Close_If");
			fprintf(f, "%s \n", "Open_Else");
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==21) // Print
		{
			free = Get_Min_Free_Reg();
			free.used++;
			free.value = ptr->DATA->Result;
			Set_Reg_Value(free);
			fprintf(f, "Print %s \n", free.value);
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==22) // close else sccope
		{
			fprintf(f, "%s \n", "Close_Else");
			ptr = ptr->Next;
		}
		else if(ptr->DATA->OpCode==23) // close while scope
		{
			fprintf(f, "JMP %s \n", ptr->DATA->Arg2);  // jmp to loop begining for new iteration
			fprintf(f, "%s : \n",ptr->DATA->Result);
			ptr = ptr->Next;
		}
		else                              // close for loop scope
		{
			fprintf(f, "JMP %s \n", "ForLoopBegin");   // jmp to loop begining for new iteration
			fprintf(f, "%s : \n",ptr->DATA->Result); 
			ptr = ptr->Next;
		}
		
		
		
	}
}


void PrintSymbolTable(FILE*f)
{
	Variable_Node * temp = ListTop;
	fprintf(f, "Used Variables :- \n");
	while (temp)
	{
		if (temp->DATA->Used)
		{
			fprintf(f, "%s of type %s\n", temp->DATA->VariableName, var_types[temp->DATA->Type]);
		}
		temp = temp->Next;
	}

	fprintf(f, "\n");
	
	
	
	temp = ListTop;
	fprintf(f, "Initilized Variables :- \n");
	while (temp)
	{
		if (temp->DATA->Initilzation)
		{
			fprintf(f, "%s of type %s\n", temp->DATA->VariableName, var_types[temp->DATA->Type]);
		}
		temp = temp->Next;
	}

	fprintf(f, "\n");
	
	temp = ListTop;
	fprintf(f, "UnUsed Variables :- \n");
	while (temp)
	{
		if (!(temp->DATA->Used))
		{
			fprintf(f, "%s of type %s\n", temp->DATA->VariableName, var_types[temp->DATA->Type]);
		}
		temp = temp->Next;
	}

	fprintf(f, "\n");
	
	
	
	temp = ListTop;
	fprintf(f, "UnInitilized Variables :- \n");
	while (temp)
	{
		if (!(temp->DATA->Initilzation))
		{
			fprintf(f, "%s of type %s\n", temp->DATA->VariableName, var_types[temp->DATA->Type]);
		}
		temp = temp->Next;
	}

	fprintf(f, "\n");
	
}
