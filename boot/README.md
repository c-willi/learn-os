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
[OSDev Wiki](https://wiki.osdev.org/PE#DOS_Stub)
The DOS header is a legacy compatibility stub. It starts with 'MZ' (0x4D5A), a magic number.
Most of the fields are unused, the only one being used is e_lfanew.
The field at 0x3C, known as e_lfanew, points to the start of the PE header.
