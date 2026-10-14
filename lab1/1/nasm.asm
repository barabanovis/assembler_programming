%include "io64.inc"

section .bss
buffer: resb 65

section .text
global main

main:
 ; Variables:
 ; EAX - a
 ; EDI - b
 ; EDX - tmp
 ; ECX - x
 GET_UDEC 4, eax
 GET_UDEC 4, edi
 cmp eax, edi
 jg if_end
 mov edx, eax
 mov eax, edi
 mov edi, edx
 if_end:
 mov ecx, edi
 sub ecx, 1
 cycle_start:
 add ecx, 1
 sub dx, dx
 div ecx, eax
 cmp dx, 0
 jne cycle_start
 sub dx, dx
 div ecx, edi
 cmp dx, 0
 jne cycle_start
 
 
 