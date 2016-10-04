; $Id: CPUIDAvail.asm,v 1.5 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

PUBLIC CPUIDAvail

IFDEF COMPILE_INFO
  PUBLIC szCPUIDAvailInfo

.data
  szCPUIDAvailInfo   Db @CompInfo, 0
ENDIF

.code
CPUIDAvail       Proc
  ; Возвращает True, если есть возможность узнать
  ; параметры процессора.

  pushfd
  pop   eax
  mov   edx,eax
  xor   eax, 0200000h
  push  eax
  popfd
  pushfd
  pop   eax
  xor   eax,edx
  and   eax, 0200000h
  shr   eax, 21
  ret
CPUIDAvail       Endp
     End
