# My First Kernel

This project is a **mini kernel written in C and Assembly** for the **x86 architecture**. The kernel is loaded using **GRUB**, displays a message on the screen, and handles keyboard inputs (AZERTY layout). The project was developed by following the blogs by Arjun Sreedharan: 
- [Kernels 101 - Let’s write a Kernel](https://arjunsreedharan.org/post/82710718100/kernels-101-lets-write-a-kernel)
- [Kernels 201 - Let’s write a Kernel with keyboard and screen support](https://arjunsreedharan.org/post/99370248137/kernels-201-lets-write-a-kernel-with-keyboard).

## Features

- Bootable using GRUB (compliant with the **Multiboot specification**).
- Clears the screen and displays an initial message.
- Handles hardware interrupts to capture keyboard events.
- Supports AZERTY keyboard layout (letters, numbers, and some symbols).

---

## How the Kernel Works

### 1. **Booting with GRUB**
The kernel is designed to be loaded by **GRUB**. During the boot process:
1. GRUB reads the **Multiboot header** embedded in `kernel.asm`.
2. GRUB loads the kernel into memory at **0x100000** (1 MB).
3. GRUB transfers control to the entry point defined in `kernel.asm` (label `start`).

### 2. **Kernel Initialization**
From the entry point:
1. Interrupts are temporarily disabled (`cli`) to avoid interference during setup.
2. The stack pointer (`esp`) is initialized to a reserved memory region (8 KB).
3. The main function `kmain` (written in C) is called.

### 3. **Peripheral Management**
The kernel uses:
- **I/O Ports** to communicate with peripherals (keyboard, PIC, etc.).
- A **Programmable Interrupt Controller (PIC)** to convert hardware signals (IRQs) into software interrupts.
- An **Interrupt Descriptor Table (IDT)** to map interrupts to their respective handlers.

### 4. **Keyboard Support**
When a key is pressed:
1. The keyboard sends a signal (**IRQ1**) to the PIC.
2. The PIC generates an interrupt (**0x21**) and notifies the processor.
3. The processor looks up the IDT and executes the interrupt handler (`keyboard_handler`).
4. The handler reads the pressed key (via port `0x60`) and displays the corresponding character on the screen.

---

## Project Files

### **1. `kernel.asm`**
The assembly file:
- Configures the **Multiboot header** for GRUB.
- Defines the entry point (`start`) and initializes the stack pointer.
- Implements functions for reading/writing to I/O ports and loading the IDT.
- Defines the keyboard interrupt handler (`keyboard_handler`).

### **2. `kernel.c`**
The C file:
- Displays an initial message on the screen.
- Initializes the Interrupt Descriptor Table (IDT) and the PIC.
- Implements keyboard event handling (with AZERTY mapping).

### **3. `link.ld`**
The linker script:
- Organizes the kernel's sections in memory (`.text`, `.data`, `.bss`).
- Sets the kernel's loading address (`0x100000`).

### **4. `build_and_run.sh`**
A shell script to:
- Install required tools (NASM, GCC, LD, QEMU).
- Assemble, compile, and link the kernel.
- Execute the kernel in QEMU.

---

## Prerequisites

### Required Tools
- **NASM**: Assembler for `kernel.asm`.
- **GCC**: Compiler for `kernel.c`.
- **LD**: Linker to create the final binary.
- **QEMU**: Emulator to test the kernel.

### Installing Tools (on Linux)
```bash
sudo apt update
sudo apt install -y nasm gcc qemu-system-x86 build-essential
```

## Compilation and Execution
Automating compilation with build.sh
To automate all the steps, run the build.sh script:

```bash
chmod +x build.sh
./build.sh
```

### Manual Compilation Steps
1. Assembling the kernel.asm file:

```bash
nasm -f elf32 kernel.asm -o kernel_asm.o
```

2. Compile the kernel.c file:

```bash
gcc -m32 -c kernel.c -o kernel_c.o -ffreestanding
```
3. Link the object files using the linker script:

```bash
ld -m elf_i386 -T link.ld -o kernel.bin kernel_asm.o kernel_c.o
```

4. Run the kernel in QEMU:

```bash
qemu-system-i386 -kernel kernel.bin
```

---

### Internal Details
1. **Multiboot and GRUB**
The Multiboot header in kernel.asm allows GRUB to:

  - Identify the kernel as Multiboot-compliant.
  - Load the kernel at the predefined memory address (0x100000).
  - Transfer control to the kernel's entry point (start).

2. Video Memory
The kernel writes directly to video memory at address 0xB8000 in text mode. Each character uses 2 bytes:

  - 1 byte for the ASCII character.
  - 1 byte for attributes (color).

3. Interrupt Handling
The kernel sets up an IDT to manage interrupts, with a specific entry for the keyboard interrupt (0x21).

4. Keyboard Support
The keyboard uses port 0x60 for data and port 0x64 for status.
A keyboard map (keyboard_map) is used to translate scancodes into characters. The project includes an AZERTY mapping.

## Limitations and Possible Extensions

### Current Limitations

  - Only letters (a-z) and digits (0-9) are supported.

  - No handling for special keys (e.g., SHIFT, ALT).

### Potential Extensions
Add support for uppercase letters and special keys (e.g., SHIFT, CTRL).
Implement a cursor to move the text display.
Add support for other devices like a mouse or disks.

## References
  - Kernels 101 - Let’s write a Kernel
  - Kernels 201 - Let’s write a Kernel with keyboard and screen support
  - OSDev Wiki - Programmable Interrupt Controller

# Special Note

I learned from the blogs written by Arjun Sreedharan, but the tutorials was destined to QWERTY keyboard, 
I managed to do the mapping of the keyboard in AZERTY, because oui,oui baguette, croissant (T-T)...
I'm inspired to write a series of blogs on how to write your own OS from scratch in a way that's easier to understand, something like "OS for Dummies". I don't know i haven't thought a lot about it, so this project will surely be more developed in the future...

---

The Linux philosophy is 'Laugh in the face of danger'. Oops. Wrong One. 'Do it yourself'. Yes, that's it. 

Linus Torvalds
