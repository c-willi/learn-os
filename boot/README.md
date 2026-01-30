# Booting with UEFI
Learn OS only boots via UEFI at the moment.
---
## Notes
Resources:
- [UEFI Spec 2.11](https://uefi.org/sites/default/files/resources/UEFI_Spec_Final_2.11.pdf)
- [Microsoft x64 ABI Overview](https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions)

### UEFI
> (U)EFI or (Unified) Extensible Firmware Interface is a specification for x86, x86-64, ARM, and Itanium platforms that defines a software interface between the operating system and the platform firmware/BIOS.
- OSDev Wiki, [UEFI](https://wiki.osdev.org/UEFI)

UEFI firmware handles platform initialization, enables the A20 line (allows accessing all physical memory), and prepares the environment (protected mode for 32-bit, long mode with [identity paging](https://wiki.osdev.org/Identity_Paging) for 64-bit).



