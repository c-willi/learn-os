; pe_header.asm ;

bits 64

; constants


section .header progbits start=0x0

; ==========
; DOS HEADER
; ==========
; 64 bytes
; A legacy header that points to the start of the PE header.
; Magic number 'MZ'.
; I'm creating a label for each field because I think it's cool to know their names.
DOS_HEADER:
    .e_magic:    db 'MZ'
    .e_cblp:     dw 0                       ; bytes on last page
    .e_cp:       dw 0                       ; number of pages
    .e_crlc:     dw 0                       ; number of entries in the relocations table
    .e_cparhdr:  dw 0                       ; size of header in paragraphs
    .e_minalloc: dw 0                       ; number of paragraphs **required**
    .e_maxalloc: dw 0                       ; number of paragraphs **requested**
    .e_ss:       dw 0                       ; segment address for SS
    .e_sp:       dw 0                       ; initial value for SP
    .e_csum:     dw 0                       ; checksum
    .e_ip:       dw 0                       ; initial value for IP
    .e_cs:       dw 0                       ; segment address for CS
    .e_lfarlc:   dw 0                       ; absolute offset for the relocation table
    .e_ovno:     dw 0                       ; value for overlay management. 0 is the main exe
    .e_res:      times 4 dw 0               ; reserved space
    .e_oemid:    dw 0                       ; OEM ID
    .e_oeminfo:  dw 0                       ; OEM Info
    .e_res2:     times 10 dw 0              ; more reserved space
    .e_lfanew:   dd PE_HEADER               ; offset to the PE header (important)

; =========
; PE HEADER
; =========
; This makes the file a PE image
PE_HEADER:
    .Signature:  db 'PE', 0, 0              ; PE\0\0 signature (magic number)

; ===========
; COFF HEADER
; ===========
COFF_HEADER:
    .Machine:   dw 0x8664                   ; AMD-64/x86-64 machine type
    .NumberOfSections: dw 2                 ; this image has .text and .data sections
    .TimeDateStamp: dd 0                    ; I'm not gonna do this lol
    .PointerToSymbolTable: dd 0             ; there is no symbol table
    .NumberOfSymbols: dd 0                  ; no symbols
    .SizeOfOptionalHeader: dw OPT_HEADER_SIZE ; TODO: size of the optional header!
    .Characteristics: dw 0x0022             ; EXECUTABLE_IMAGE (0x0002) | LARGE_ADDRESS_AWARE (0x0020)
