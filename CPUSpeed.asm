; $Id: CPUSpeed.asm,v 1.7 2004/07/27 07:49:00 Павел Exp $
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
  ; Возвращает кол-во мегагерц процессора в Eax
  LOCAL TimerHi, TimerLo,
        PriorityClass, Priority,
        hProcess, hThread:DWORD

  ; Сохраняем класс приоритета процесса
  mov    eax, @Result(GetCurrentProcess)
  mov    PriorityClass, @Result(GetPriorityClass, eax)
  
  ; Сохраняем приоритет потока
  mov    eax, @Result(GetCurrentThread)
  mov    Priority, @Result(GetThreadPriority, eax)

  ; Берем идентификаторы процесса и потока
  mov    hProcess, @Result(GetCurrentProcess)
  mov    hThread, @Result(GetCurrentThread)

  ; Выставляем приоритеты процесса и потока
  invoke SetPriorityClass, hProcess, REALTIME_PRIORITY_CLASS
  invoke SetThreadPriority, hThread, THREAD_PRIORITY_TIME_CRITICAL

  ; Ждем немного
  invoke Sleep, 10

  ; Первый замер
  rdtsc
  mov    TimerLo, eax
  mov    TimerHi, edx

  invoke Sleep, DelayTime

  ; Второй замер
  rdtsc
  sub    eax, TimerLo
  sub    edx, TimerHi
  mov    TimerLo, eax
  mov    TimerHi, edx

  push   eax

  ; Восстанавливаем приоритеты процесса и потока
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
