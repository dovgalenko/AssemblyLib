; Процедуры взятые из проекта Kernel, by y0da.
;
; $Id: KernelBase.Asm,v 1.4 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start

PUBLIC yodaGetKernelBase
PUBLIC yodaGetProcAddr

IFDEF COMPILE_INFO
  PUBLIC szKernelBaseInfo

.data
  szKernelBaseInfo   Db @CompInfo, 0
ENDIF

MIN_KERNEL_SEARCH_BASE    EQU 070000000h
MAX_API_STRING_LENGTH     EQU 150

sSEH STRUCT
  OrgEsp      DD ?
  OrgEbp      DD ?
  SaveEip     DD ?
sSEH ENDS

.data?
SEH           sSEH <>

.code
; Возвращает адрес Kernel32, либо NULL в случае ошибки
; Пример использования:
;   push [Esp]
;   call yodaGetKernelBase
yodaGetKernelBase  Proc USES Edi Esi dwTopStack : DWORD
  ; install SEH frame
  Assume FS:Nothing
  push OFFSET SehHandler
  push FS:[0]
  mov  SEH.OrgEsp, Esp
  mov  SEH.OrgEbp, Ebp
  mov  SEH.SaveEip, OFFSET ExceptCont
  mov  FS:[0], ESP

  ; start the search
  mov  Edi, dwTopStack
  and  Edi, 0FFFF0000h    ; wipe the LOWORD !
  .while TRUE
    .if Word Ptr [Edi] == IMAGE_DOS_SIGNATURE
      mov  Esi, Edi
      add  Esi, [Esi+03Ch]
      .if  DWord Ptr [Esi] == IMAGE_NT_SIGNATURE
        .break
      .endif
    .endif

  ExceptCont:
    sub  Edi, 010000h
    .if Edi < MIN_KERNEL_SEARCH_BASE
      mov  Edi, 0BFF70000h
      .break
    .endif
  .endw
  xchg Eax, Edi 
  
  ; shutdown SEH frame
  pop  FS:[0]
  add  Esp, 4
  ret
yodaGetKernelBase  Endp

yodaGetProcAddr Proc USES ESI EDI ECX EBX EDX, dwDllBase : DWORD, szApi : LPSTR

  ; install SEH frame
  Assume FS:Nothing
  push OFFSET SehHandler
  push FS:[0]
  mov  SEH.OrgEsp, Esp
  mov  SEH.OrgEbp, Ebp
  mov  SEH.SaveEip, OFFSET @@BadExit
  mov  FS:[0], Esp
  
  ; check PE Signarue
  mov  Esi, dwDllBase
  cmp  Word Ptr [Esi], IMAGE_DOS_SIGNATURE
  jnz @@BadExit
  add  Esi, [Esi+03Ch]
  cmp  DWord Ptr [Esi], IMAGE_NT_SIGNATURE
  jnz @@BadExit
  
  ; get the string length of the target Api
  mov  Edi, szApi
  mov  Ecx, MAX_API_STRING_LENGTH
  xor  Al, Al
  repnz  scasb
  mov  Ecx, Edi
  sub  Ecx, szApi       ; ECX -> Api string length
  
  ; trace the export table
  mov  Edx, [Esi+078h]        ; EDX -> Export table
  add  Edx, dwDllBase
  Assume Edx :Ptr IMAGE_EXPORT_DIRECTORY       
  mov  Ebx, [Edx].AddressOfNames    ; EBX -> AddressOfNames array pointer
  add  Ebx, dwDllBase
  xor  Eax, Eax         ; EAX AddressOfNames Index
  .repeat
    mov  Edi, [Ebx]
    add  Edi, dwDllBase
    mov  Esi, szApi
    push Ecx          ; save the api string length
    repz cmpsb
    .if zero?
      add  Esp, 4
      .break
    .endif
    pop  Ecx
    add  Ebx, 4
    inc  Eax   
  .until Eax == [Edx].NumberOfNames
  
  ; did we found sth ?
  .if Eax == [Edx].NumberOfNames
    jmp @@BadExit
  .endif
  
  ; find the corresponding Ordinal
  mov  Esi, [Edx].AddressOfNameOrdinals
  add  Esi, dwDllBase
  push Edx          ; save the export table pointer
  mov  Ebx, 2
  xor  Edx, Edx
  mul  Ebx
  pop  Edx
  add  Eax, Esi
  xor  Ecx, Ecx
  mov  Word Ptr Cx, [Eax]     ; ECX -> Api Ordinal
  
  ; get the address of the api
  mov  Edi, [Edx].AddressOfFunctions
  xor  Edx, Edx
  mov  Ebx, 4
  mov  Eax, Ecx
  mul  Ebx
  add  Eax, dwDllBase
  add  Eax, Edi
  mov  Eax, [Eax]
  add  Eax, dwDllBase
  jmp  @@ExitProc
  
  Assume Edx :Nothing 
    
  @@BadExit:
    xor  Eax, Eax   
   @@ExitProc:

  ; shutdown SEH frame
  pop  FS:[0]
  add  Esp, 4
  ret
yodaGetProcAddr Endp

SehHandler  Proc C pExcept, pFrame, pContext, pDispatch:DWORD

  mov  Eax, pContext
  Assume Eax : Ptr CONTEXT
  push SEH.SaveEip
  pop  [Eax].regEip
  push SEH.OrgEsp
  pop  [Eax].regEsp
  push SEH.OrgEbp
  pop  [Eax].regEbp
  mov  Eax, ExceptionContinueExecution
  ret
SehHandler  Endp
            End
