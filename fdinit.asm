; $Id: fdinit.asm,v 1.4 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

PUBLIC FdInit

EXTERNDEF STDCALL FdZero  :PROTO STDCALL :DWORD
EXTERNDEF STDCALL FdSet   :PROTO STDCALL :DWORD, :DWORD

IFDEF COMPILE_INFO
  PUBLIC szFdInitInfo

.data
  szFdInitInfo   Db @CompInfo, 0
ENDIF

.code
FdInit           Proc Sock:DWORD, lpFd:DWORD

  invoke FdZero, lpFd
  invoke FdSet, Sock, lpFd
  Ret
FdInit           Endp
     End
