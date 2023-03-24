.assembly extern mscorlib {}
.assembly program {}
.module program.exe
.class public program
{
	.method public static void main()
	{
		.entrypoint
		.maxstack 0
		.locals init (
		)
		ldc.i4	345
		ldc.i4	98
		mul
		call void class [mscorlib]System.Console::WriteLine(int32)
	ret
	}
}
