; $Id: fdset.asm,v 1.5 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

PUBLIC FdSet

IFDEF COMPILE_INFO
  PUBLIC szFdSetInfo

.data
  szFdSetInfo   Db @CompInfo, 0
ENDIF

.code
FdSet            Proc USES Eax Ebx Edx Sock:DWORD, lpFd:DWORD
  LOCAL FdCount:DWORD

  mov   ebx, lpFd

  mov   eax, (fd_set Ptr [ebx]).fd_count
  mov   edx, Sock
  push  ebx
  lea   ebx, (fd_set Ptr [ebx]).fd_array
  mov   Dword Ptr [ebx + eax * SIZEOF DWORD], edx
  inc   eax
  pop   ebx
  mov   (fd_set Ptr [ebx]).fd_count, eax
  ret
FdSet            Endp
     End
