#if defined(CL_WIN16) || defined(CL_WIN32)
#define CL_WINDOWS
#endif

#ifdef CL_WIN32
#define WIN32
#endif

#ifdef CL_WINDOWS
#include <Windows.h>
#endif

#ifdef CL_WIN32
// for /subsyste:windows
INT WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    INT nCmdShow)
#else
int main()
#endif
{
#if defined(CL_DOS) || defined(CL_QUICKWIN)
    puts("Hello world!");
#endif

#if defined(CL_WINDOWS)
    MessageBox(NULL, "Hello world!\n", "Greetings", 0);
#endif
	return 0;
}