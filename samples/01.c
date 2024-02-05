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
	return 0;
}
