static int s_testData = 0x22222222;  // This will be in the DATA section
static int s_testBSS; // This will be in the BSS section

void IncLong(int *a) 
{
	*a += 1;
}
