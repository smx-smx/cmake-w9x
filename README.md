## cmake-w9x
CMake glue to use MSC 4.0, MSVC 1.x and 2.x with modern CMake

Specifically, this makes it possible to target

- DOS
- Windows 1.x/2.x (needs Microsoft C 4.0 with the Windows 1.x/2.x SDK)
- Win16 (including QuickWin)
- Win32/Win32s (Win9x and WinNT)

NOTE: only the "MinGW Makefiles" generator is supported. Sample build scripts can be found under the "samples" folder
