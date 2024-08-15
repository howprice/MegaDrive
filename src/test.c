// Initialised data goes in the DATA section
// n.b. Must initialise to non-zero value, otherwise it goes in BSS
static int s_incCountData = 1;  
static int s_decCountData = 1;  

// Uninitialised data goes in the BSS section
static int s_incCountBSS; 
static int s_decCountBSS; 

void IncLong(int *pVal) 
{
	*pVal += 1;
	s_incCountData++;
	s_incCountBSS++;
}

void DecLong(int *pVal) 
{
	*pVal -= 1;
	s_decCountData++;
	s_decCountBSS++;
}
