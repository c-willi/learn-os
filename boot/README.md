# Booting with UEFI
Learn OS only boots via UEFI at the moment.

## Notes
Resources:
- [UEFI Spec 2.11](https://uefi.org/sites/default/files/resources/UEFI_Spec_Final_2.11.pdf)
- [Microsoft x64 ABI Overview](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions)

### UEFI
> (U)EFI or (Unified) Extensible Firmware Interface is a specification for x86, x86-64, ARM, and Itanium platforms that defines a software interface between the operating system and the platform firmware/BIOS.
- OSDev Wiki, [UEFI](https://wiki.osdev.org/UEFI)

UEFI firmware handles platform initialization, enables the A20 line (allows accessing all physical memory), and prepares the environment (protected mode for 32-bit, long mode with [identity paging](https://wiki.osdev.org/Identity_Paging) for 64-bit).

The UEFI firmware loads a UEFI application from a FAT partition on a GPT or MBR partitioned boot drive to an address selected at runtime. From there, it calls the application's entry point.

An application must use a PE32+ image format with a modified header signature.

#### PE32+ Image Format
1. **DOS Stub** (64 bytes)
2. **Real mode executable code** (usually skipped)
3. **PE Header** (4 bytes)
4. **COFF Header** (20 bytes)
5. **Optional Header** (112 bytes)
6. **Section Headers** (40 bytes each)
7. **.text Section**
8. **.data Section**

##### The DOS Stub
[OSDev Wiki](https://wiki.osdev.org/MZ)
The DOS header is a legacy compatibility stub. It starts with 'MZ' (0x4D5A), a magic number.
Most of the fields are unused, the only one being used is e_lfanew.
The field at 0x3C, known as e_lfanew, points to the start of the PE header.
There's a lot of stuff to learn about this one but it's not really "used" for a PE32+ image.

##### The PE Header
The PE header holds information on the entire file. The magic number 'PE\0\0' (0x00004550) is the bare minimum needed to 
define the header.

##### COFF COFF
[Microsft PE Format](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#coff-file-header-object-and-image)
[OSDev Wiki](https://wiki.osdev.org/COFF)
This header specifies things like the machine type, and the number of sections (`.text`, `.data`).
It describes the structure of the image.
COFF stands for Common Object File Format.

| Field | Size | Description |
|:--    |:-:   | :--         |
| Machine | 2 | Identifies the target machine's type |
| NumberOfSections | 2 | Size of the section table |
| TimeDateStamp | 4 | Number of seconds since 00:00 Jan 1, 1970 indicating when the file was created |
| PointerToSymbolTable | 4 | Should be 0. Points to a COFF symbol table |
| NumberOfSymbols | 4 | This should be 0 too. The number of entries in the symbol table |
| SizeOfOptionalHeader | 2 | The size of the optional header |
| Characteristics | 2 | File attribute flags |

The symbol table is deprecated, so everything related should be set to 0.

For the machine type, I'm targeting x86-64, so the field's value is 0x8664.
**Characteristics**:
- EXECUTABLE_IMAGE (0x0002): Marks the file as executable.
- LARGE_ADDRESS_AWARE (0x0020): Addressing >2GB addresses

