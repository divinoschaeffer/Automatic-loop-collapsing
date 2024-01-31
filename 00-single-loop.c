int main() {
	int i;
	#pragma scop	
	for (i = 0; i < 30; i++) (void) i;
	#pragma endscop
	return 0;
}
