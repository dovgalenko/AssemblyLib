; $Id: IsInetConnected.Asm,v 1.2 2004/07/27 08:50:50 Павел Exp $
;
include macros.inc

@Start

PUBLIC IsInetConnected

IFDEF COMPILE_INFO
  PUBLIC szIsInetConnectedInfo

.data
  szIsInetConnectedInfo   Db @CompInfo, 0
ENDIF

.code
IsInetConnected  Proc

  ret
IsInetConnected  Endp
                 End