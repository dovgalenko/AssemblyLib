; $Id: fdzero.asm,v 1.5 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

PUBLIC FdZero

IFDEF COMPILE_INFO
  PUBLIC szFdZeroInfo

.data
  szFdZeroInfo   Db @CompInfo, 0
ENDIF

.code
FdZero           Proc USES Ebx lpFd:DWORD

  mov   ebx, lpFd
  mov   (fd_set Ptr [ebx]).fd_count, 0
  ret
FdZero           Endp
     End
