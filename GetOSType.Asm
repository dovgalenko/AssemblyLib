; $Id: GetOSType.Asm,v 1.5 2004/07/27 07:49:00 Павел Exp $
;
include macros.inc

@Start
@Uses Kernel32

include Const.Inc

VER_SERVER_NT                       Equ 80000000h 
VER_WORKSTATION_NT                  Equ 40000000h 
VER_SUITE_SMALLBUSINESS             Equ 00000001h
VER_SUITE_ENTERPRISE                Equ 00000002h
VER_SUITE_BACKOFFICE                Equ 00000004h
VER_SUITE_COMMUNICATIONS            Equ 00000008h
VER_SUITE_TERMINAL                  Equ 00000010h
VER_SUITE_SMALLBUSINESS_RESTRICTED  Equ 00000020h
VER_SUITE_EMBEDDEDNT                Equ 00000040h
VER_SUITE_DATACENTER                Equ 00000080h
VER_SUITE_SINGLEUSERTS              Equ 00000100h
VER_SUITE_PERSONAL                  Equ 00000200h
VER_SUITE_BLADE                     Equ 00000400h
VER_SUITE_EMBEDDED_RESTRICTED       Equ 00000800h
VER_SUITE_SECURITY_APPLIANCE        Equ 00001000h

VER_NT_WORKSTATION                  Equ 0000001h
VER_NT_DOMAIN_CONTROLLER            Equ 0000002h
VER_NT_SERVER                       Equ 0000003h

OSVERSIONINFOEX STRUCT
  dwOSVersionInfoSize DWORD ?
  dwMajorVersion  DWORD ?
  dwMinorVersion  DWORD ?
  dwBuildNumber   DWORD ?
  dwPlatformId    DWORD ?
  szCSDVersion    BYTE  128  dup (?)
  wServicePackMajor WORD ?
  wServicePackMinor WORD ?
  wSuiteMask      WORD ?
  wProductType    BYTE ?
  wReserved       BYTE ?
OSVERSIONINFOEX ENDS

IFDEF COMPILE_INFO
  PUBLIC szGetOSTypeInfo

.data
  szGetOSTypeInfo   Db @CompInfo, 0
ENDIF

.code
GetOSType        Proc
; Проверка типа операционной системы пользователя
  LOCAL  VerEx  :DWORD
  LOCAL  Ver    :OSVERSIONINFOEX
  LOCAL  Result :DWORD

  mov    Ver.dwOSVersionInfoSize, SIZEOF OSVERSIONINFOEX
  mov    VerEx, @Result(GetVersionEx, ADDR Ver)
  .if !VerEx
    ; Расширенная информация не доступна
    mov    Ver.dwOSVersionInfoSize, SIZEOF OSVERSIONINFO
    invoke GetVersionEx, ADDR Ver
  .endif

  ; Берем данные ОС
  .if Ver.dwPlatformId == VER_PLATFORM_WIN32_NT
    ; Определение версии системы
    .if (Ver.dwMajorVersion == 5) && (Ver.dwMinorVersion == 2)
      ; Microsoft Windows Server 2003
      mov   Result, OS_WINDOWS_2003
    .elseif (Ver.dwMajorVersion == 5) && (Ver.dwMinorVersion == 1)
      ; Microsoft Windows XP
      mov   Result, OS_WINDOWS_XP
    .elseif (Ver.dwMajorVersion == 5) && (Ver.dwMinorVersion == 0)
      ; Microsoft Windows 2000
      mov   Result, OS_WINDOWS_2000
    .elseif Ver.dwMajorVersion <= 4
      ; Microsoft Windows NT
      mov   Result, OS_WINDOWS_NT
    .endif

    ; Проверка доп. данных ОС
    .if VerEx
      ; Проверка систем Windows NT 4.0 SP6 and later.

      ; Проверка систем типа Workstation
      .if Ver.wProductType == VER_NT_WORKSTATION
        .if Ver.dwMajorVersion == 4
          ; Workstation
          inc   Result

        .elseif Ver.wSuiteMask & VER_SUITE_PERSONAL
          ; Home edition
          add   Result, 2
        .else
          ; Professional
          add   Result, 3
        .endif
      .endif

      ; Проверка систем типа Server
      .if ((Ver.wProductType == VER_NT_SERVER) || \
          (Ver.wProductType == VER_NT_DOMAIN_CONTROLLER))
        .if (Ver.dwMajorVersion == 5) && (Ver.dwMinorVersion == 2)
          .if Ver.wSuiteMask & VER_SUITE_DATACENTER
            ; Microsoft Windows Server 2003 Datacenter Edition
            mov   Result, OS_WINDOWS_2003_DATA

          .elseif Ver.wSuiteMask & VER_SUITE_ENTERPRISE
            ; Microsoft Windows Server 2003 Advanced Server
            mov   Result, OS_WINDOWS_2003_ENT

          .elseif Ver.wSuiteMask & VER_SUITE_BLADE
            ; Microsoft Windows Server 2003 Web Server
            mov   Result, OS_WINDOWS_2003_WEB

          .else
            ; Microsoft Windows Server 2003 Standard Server
            mov   Result, OS_WINDOWS_2003_STD
          .endif

        .elseif (Ver.dwMajorVersion == 5) && (Ver.dwMinorVersion == 0)
          .if Ver.wSuiteMask & VER_SUITE_DATACENTER
            ; Microsoft Windows 2000 Datacenter Server
            mov   Result, OS_WINDOWS_2000_DATA

          .elseif Ver.wSuiteMask & VER_SUITE_ENTERPRISE
            ; Microsoft Windows 2000 Advanced Server
            mov   Result, OS_WINDOWS_2000_ADV
          .else
            ; Microsoft Windows 2000 Server
            mov   Result, OS_WINDOWS_2000_SERV
          .endif
        .else
          .if Ver.wSuiteMask & VER_SUITE_ENTERPRISE
            ; Microsoft Windows NT4 Server, Enterprise Edition
            mov   Result, OS_WINDOWS_SERVER_ENT
          .else
            ; Microsoft Windows NT4 Server
            mov   Result, OS_WINDOWS_SERVER_STD
          .endif
        .endif
      .endif
    .else
      ; Проверка систем Windows NT 4.0 SP5 и младше
    .endif
  .elseif Ver.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
    push   ebx
    lea    ebx, Ver.szCSDVersion
    inc    ebx
    .if (Ver.dwMajorVersion == 4) && (Ver.dwMinorVersion == 0)
      ; Microsoft Windows 95
      mov   Result, OS_WINDOWS_95
      .if (Byte Ptr[ebx] == 'C') || (Byte Ptr[ebx] == 'B')
        ; Microsoft Windows 95 OSR2
        mov   Result, OS_WINDOWS_95_OSR2
      .endif
    .elseif (Ver.dwMajorVersion == 4) && (Ver.dwMinorVersion == 10)
      ; Microsoft Windows 98
      mov   Result, OS_WINDOWS_98
      .if (Byte Ptr[ebx] == 'A')
        ; Microsoft Windows 98 Second Edition
        mov   Result, OS_WINDOWS_98_SE
      .endif
    .elseif (Ver.dwMajorVersion == 4) && (Ver.dwMinorVersion == 90)
      ; Microsoft Windows Millenium Edition
      mov   Result, OS_WINDOWS_ME
    .endif
    pop    ebx

  .elseif Ver.dwPlatformId == VER_PLATFORM_WIN32s
    ; Microsoft Win32s
    mov   Result, OS_WIN32s
  .endif

  mov     eax, Result
  ret
GetOSType        Endp
                 End