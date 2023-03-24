.assembly extern mscorlib {}
.assembly program {}
.module program.exe
.class public program
{
.method public static void main()
{
.entrypoint
.maxstack 100
 ldc.i4 1
 ldc.i4 1
 add
 call void class [mscorlib]System.Console::WriteLine(int32)
ret
}
}