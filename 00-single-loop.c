int main() {
	int i;
	int j;
	int k;
	int l;
	#pragma scop	
	for (i = 0; i < 30; i++) 
	for (j = 2; j < 43; j++)
	(void) i;
	#pragma endscop
	#pragma scop	
	for (i = 0; i < 30; i++) 
	for (j = 2; j < 43; j++)
	for (k = 98; k > 23 || l > 9; k--)
	(void) i;
	#pragma endscop
	return 0;
}
