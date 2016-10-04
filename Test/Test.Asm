include \masm32\macros\macros.inc

@Start
@Uses Kernel32, User32, ChemistLib

.data
szCPUSpeed    Db 'CPU Speed: %dHz', 0
szOSType      Db 'OS Type : %d', 0

.code
Output   Proc lpStr, dwData:DWORD
  LOCAL  szBuff[255]:DWORD

  invoke RtlZeroMemory, ADDR szBuff, 255
  invoke wsprintf, ADDR szBuff, lpStr, dwData
  invoke OutputDebugString, ADDR szBuff
  ret
Output   Endp

WinMain  Proc
  LOCAL  Brand[50]:DWORD

  invoke CPUIDAvail
  .if eax
    invoke CPUBrand, ADDR Brand, 50
    invoke OutputDebugString, ADDR Brand
    invoke CPUSpeed
    invoke Output, OFFSET szCPUSpeed, eax

    invoke GetOSType
    invoke Output, OFFSET szOSType, eax
  .endif
  invoke ExitProcess, 0
  ret
WinMain  Endp
         End WinMain