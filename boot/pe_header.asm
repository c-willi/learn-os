; pe_header.asm ;

bits 64

; constants

FILE_ALIGN equ 0x200                        ; 512 byte alignment
SECTION_ALIGN equ 0x1000                    ; 4096 section aligment
HEADER_SIZE equ 0x200                       ; headers occupy first 512 bytes

TEXT_FILE_SIZE equ 0x200                    ; .text is 512 bytes
DATA_FILE_SIZE equ 0x200                    ; as is .data

TEXT_RVA equ 0x1000                         ; .text relative virtual address starts at 4K in memory
DATA_RVA equ 0x2000                         ; .data is at 8K

TEXT_V_SIZE equ 0x1000                      ; .text takes up 4K of virtual memory, rounded to section aligment
DATA_V_SIZE equ 0x1000                      ; same with .data

IMAGE_SIZE equ 0x3000                       ; 12K total size

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
; Basic structure
COFF_HEADER:
    .Machine:   dw 0x8664                   ; AMD-64/x86-64 machine type
    .NumberOfSections: dw 2                 ; this image has .text and .data sections
    .TimeDateStamp: dd 0                    ; I'm not gonna do this lol
    .PointerToSymbolTable: dd 0             ; there is no symbol table
    .NumberOfSymbols: dd 0                  ; no symbols
    .SizeOfOptionalHeader: dw OPT_HEADER_SIZE ; size of the optional header
    .Characteristics: dw 0x0022             ; EXECUTABLE_IMAGE (0x0002) | LARGE_ADDRESS_AWARE (0x0020)

; ===============
; OPTIONAL HEADER
; ===============
OPTIONAL_HEADER:
    .Magic:     dw 0x020b                   ; 64-bit magic number
    .MajorLinkerVersion: db 0
    .MinorLinkerVersion: db 0
    .SizeOfCode: dd TEXT_FILE_SIZE          ; size of the .text section
    .SizeOfInitializedData: dd DATA_FILE_SIZE ; size of the .data section
    .SizeOfUninitializedData: dd 0          ; no .bss
    .AddressOfEntryPoint: dd _start - $$ + TEXT_RVA ; rva of _start
    .BaseOfCode: dd TEXT_RVA                ; rva of .text
    ; pe32+ info
    .ImageBase: dq 0                        ; load address
    .SectionAlignment: dd SECTION_ALIGN     ; alignment in memory
    .FileAlignment: dd FILE_ALIGN           ; alignment in file
    .MajorOperatingSystemVersion: dw 0      ; none!
    .MinorOperatingSystemVersion: dw 0
    .MajorImageVersion: dw 0
    .MinorImageVersion: dw 0
    .MajorSubsystemVersion: dw 0
    .MinorSubsystemVersion: dw 0
    .Win32VersionValue: dd 0                ; reserved. must be 0
    .SizeOfImage: dd IMAGE_SIZE             ; total size of this
    .SizeOfHeaders: dd HEADER_SIZE          ; too many headers, tedious!!
    .CheckSum: dd 0                         ; UEFI does not care
    .Subsystem: dw 10                       ; 10 = EFI application
    .DllCharacteristics: dw 0               ; what is this? windows?
    .SizeOfStackReserve: dq 0
    .SizeOfStackCommit: dq 0
    .SizeOfHeapReserve: dq 0
    .SizeOfHeapCommit: dq 0
    .LoaderFlags: dd 0
    .NumberOfRvaAndSizes: dd 0              ; no data directories yet
    
OPT_HEADER_SIZE equ $ - OPTIONAL_HEADER