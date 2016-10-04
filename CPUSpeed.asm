; $Id: CPUSpeed.asm,v 1.7 2004/07/27 07:49:00 ����� Exp $
;
include macros.inc

@Start

@Uses Kernel32

PUBLIC CPUSpeed

IFDEF COMPILE_INFO
  PUBLIC szCPUSpeedInfo

.data
  szCPUSpeedInfo   Db @CompInfo, 0
ENDIF

DelayTime   Equ 500

.code
CPUSpeed         Proc USES Ebx Edx
  ; ���������� ���-�� �������� ���������� � Eax
  LOCAL TimerHi, TimerLo,
        PriorityClass, Priority,
        hProcess, hThread:DWORD

  ; ��������� ����� ���������� ��������
  mov    eax, @Result(GetCurrentProcess)
  mov    PriorityClass, @Result(GetPriorityClass, eax)
  
  ; ��������� ��������� ������
  mov    eax, @Result(GetCurrentThread)
  mov    Priority, @Result(GetThreadPriority, eax)

  ; ����� �������������� �������� � ������
  mov    hProcess, @Result(GetCurrentProcess)
  mov    hThread, @Result(GetCurrentThread)

  ; ���������� ���������� �������� � ������
  invoke SetPriorityClass, hProcess, REALTIME_PRIORITY_CLASS
  invoke SetThreadPriority, hThread, THREAD_PRIORITY_TIME_CRITICAL

  ; ���� �������
  invoke Sleep, 10

  ; ������ �����
  rdtsc
  mov    TimerLo, eax
  mov    TimerHi, edx

  invoke Sleep, DelayTime

  ; ������ �����
  rdtsc
  sub    eax, TimerLo
  sub    edx, TimerHi
  mov    TimerLo, eax
  mov    TimerHi, edx

  push   eax

  ; ��������������� ���������� �������� � ������
  invoke SetPriorityClass, hProcess, PriorityClass
  invoke SetThreadPriority, hThread, Priority

  mov    edx, 1000
  imul   ebx, edx, DelayTime

  xor    edx, edx
  pop    eax
  idiv   ebx
  ret
CPUSpeed         Endp
     End
