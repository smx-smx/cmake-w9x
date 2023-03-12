#include "config.h"

#ifdef CL_WINDOWS
#include <Windows.h>
#endif

#if defined(CL_WIN32)
// for /subsystem:windows
INT WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    INT nCmdShow)
#elif defined(CL_WIN16)
int PASCAL WinMain( hInstance, hPrev, lpszCmdLine, cmdShow )
#elif defined(CL_DOS)
int main (argc, argv)
    int argc;
    char *argv[];
#endif
    {

#if defined(CL_DOS) || defined(CL_QUICKWIN)
    puts("Hello world!");
#endif

#if 0
    HWND hwnd = NULL;
    hwnd = CreateWindow(
              (LPSTR) "Test",
              (LPSTR) "",
              WS_TILEDWINDOW | WS_HSCROLL | WS_VSCROLL,
              0, 0, 0, 100,
              NULL, NULL,
              hInstance,
              (LPSTR)NULL);

    MessageBox(hwnd, "Hello Everyone :)", "Smx says Hi", MB_OK);
#endif

#if defined(CL_WINDOWS)
    MessageBox(NULL, "Hello world!\n", "Greetings", 0);
#endif
	return 0;
}