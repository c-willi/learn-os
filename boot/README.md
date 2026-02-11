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
5. **Optional Header**
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

##### Optional Header
This header isn't optional. It starts with a magic number, either 0x10b for PE32 or 0x20b for PE32+ (or 0x0107 for ROM).
The optional header specifies the entry point, image layout, and data directories. The size of this header can vary, hence the SizeOfOptionalHeader field in the COFF header.

The optional header has 8 standard fields:
| Field | Size | Description |
|:--|:-:|:--|
|Magic|2|Unsigned integer representing the state of the image|
|MajorLinkerVersion|1|Major linker version|
|MinorLinkerVersion|1|Minor linker version|
|SizeOfCode|4|The size of the code/text section, or the sum of all code sections|
|SizeOfInitializedData|4|Size of the initialized data section(s)|
|SizeOfUninitializedData|4|Size of the uninitialized data (BSS) section(s)|
|AddressOfEntryPoint|4|Address for the entry point of the image|
|BaseOfCode|Image relative address for the base of the code section|

For PE32+ images, there are additional fields in the header:
| Field | Size | Description |
|:--|:-:|:--|
|ImageBase|8|The preferred address of the first byte when loaded into memory. Must be a multiple of 64K|
|SectionAlignment|4|Alignment (in bytes) of the sections when they are loaded into memory|
|FileAlignment|4|The alignment factor, in bytes, used to align raw data of sections in the image file. Must be a power of 2 and between 512 and 64K, inclusive|
|MajorOperatingSystemVersion|2|Major version number of the OS|
|MinorOperatingSystemVersion|2|Minor version number of the OS|
|MajorImageVersion|2|Major version number of the image itself|
|MinorImageVersion|2|Minor version number of the image|
|MajorSubsystemVersion|2|Major version number of the subsystem|
|MinorSubsystemVersion|2|Minor version number of the subsystem|
|Win32VersionValue|4|Reserved, must be 0|
|SizeOfImage|4|Size of the entire image, headers included. Must be a multiple of SectionAlignment|
|SizeOfHeaders|4|Combined size of DOS stub, PE header, and section headers rounded up to a multiple of FileAlignment|
|CheckSum|4|Checksum of the image file|
|Subsystem|2|Subsystem required to run the image. 10 specifies UEFI|
|DllCharacteristics|2|Not used for this|
|SizeOfStackReserve|8|Size of the stack to reserve. Only SizeOfStackCommit is commited, further stack is made available one page at a time until SizeOfStackReserve is reached|
|SizeOfStackCommit|8|Size of the stack to commit|
|SizeOfHeapReserve|8|Size of local heap space to reserve|
|SizeOfHeapCommit|8|How much heap is committed|
|LoaderFlags|4|Reserved, must be 0|
|NumberOfRvaAndSizes|4|The number of data-directory entries in the remainder of the optional header|