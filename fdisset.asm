; $Id: fdisset.asm,v 1.4 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

PUBLIC FdIsSet

IFDEF COMPILE_INFO
  PUBLIC szFdIsSetInfo

.data
  szFdIsSetInfo   Db @CompInfo, 0
ENDIF

.code
FdIsSet          Proc USES Ebx Ecx Sock:DWORD, lpFd:DWORD
  LOCAL Result:DWORD

  mov   Result, FALSE

  mov   ebx, lpFd
  mov   ecx, (fd_set Ptr [ebx]).fd_count
  lea   ebx, (fd_set Ptr [ebx]).fd_array

  .if ecx
    .repeat
      dec   ecx
      mov   eax, Dword Ptr [ebx + ecx * SIZEOF DWORD]

      .if eax == Sock
        mov   Result, TRUE
      .endif
    .until Ecx == 0 || Result == TRUE
  .endif

  mov   eax, Result
  ret
FdIsSet          Endp
     End
