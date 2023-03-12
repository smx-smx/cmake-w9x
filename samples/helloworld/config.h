#if defined(T0)
#define CL_DOS
#endif

#if defined(T1) || defined(T2)
#define CL_WIN16
#if defined(T2)
#define CL_QUICKWIN
#endif
#define CL_WINDOWS
#endif

#if defined(T3)
#define WIN32
#define CL_WIN32
#define CL_WINDOWS
#endif
