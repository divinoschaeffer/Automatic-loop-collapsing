int main() {
	int i;
	int j;
	int k;
	int l;
	#pragma scop	
	for (i = 0; i < 30; i++) 
	(void) i;
	#pragma endscop
	return 0;
}
