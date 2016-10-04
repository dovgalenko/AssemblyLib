; $Id: CPUBrand.Asm,v 1.7 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

@Uses Kernel32

PUBLIC CPUBrand

EXTERNDEF STDCALL CPUIDAvail   :PROTO

IFDEF COMPILE_INFO
  PUBLIC szCPUBrandInfo

.data
  szCPUBrandInfo   Db @CompInfo, 0
ENDIF

.code
CPUBrand         Proc USES Ebx lpBuff:DWORD, dwBuffSize:DWORD


  invoke CPUIDAvail
  .if eax && dwBuffSize >= 50
    ; Обнуляем полученный буфер от возможного мусора
    invoke RtlZeroMemory, lpBuff, dwBuffSize

    ; Получаем данные процессора
    mov  eax,080000000h
    cpuid
    cmp  eax,080000004h
    jb   @@endbrandstr

    mov  edi, lpBuff

    mov  eax,080000002h
    cpuid
    mov  DWord Ptr [edi], eax
    mov  DWord Ptr [edi+4], ebx
    mov  DWord Ptr [edi+8], ecx
    mov  DWord Ptr [edi+12], edx

    mov  eax, 080000003h
    cpuid
    mov  DWord Ptr [edi+16], eax
    mov  DWord Ptr [edi+20], ebx
    mov  DWord Ptr [edi+24], ecx
    mov  DWord Ptr [edi+28], edx

    mov  eax,080000004h
    cpuid
    mov  DWord Ptr [edi+32], eax
    mov  DWord Ptr [edi+36], ebx
    mov  DWord Ptr [edi+40], ecx
    mov  DWord Ptr [edi+44], edx
  @@endbrandstr:
  .endif
  ret
CPUBrand         Endp
     End
