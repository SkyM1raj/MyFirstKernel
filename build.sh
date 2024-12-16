#!/bin/bash

# Installation des outils nécessaires
echo "Vérification et installation des outils nécessaires..."

# Mettez à jour les paquets
sudo apt update

# Installer les outils si nécessaires
sudo apt install -y nasm gcc qemu-system-x86 build-essential

# Vérifier si les outils sont bien installés
if ! command -v nasm &> /dev/null; then
    echo "Erreur : NASM n'est pas installé correctement."
    exit 1
fi

if ! command -v gcc &> /dev/null; then
    echo "Erreur : GCC n'est pas installé correctement."
    exit 1
fi

if ! command -v ld &> /dev/null; then
    echo "Erreur : LD (linker) n'est pas installé correctement."
    exit 1
fi

if ! command -v qemu-system-i386 &> /dev/null; then
    echo "Erreur : QEMU n'est pas installé correctement."
    exit 1
fi

echo "Tous les outils nécessaires sont installés."

# Étape 1 : Assembler le fichier kernel.asm
echo "Assemblage de kernel.asm..."
nasm -f elf32 kernel.asm -o kernel_asm.o
if [ $? -ne 0 ]; then
    echo "Erreur : Problème avec l'assemblage de kernel.asm"
    exit 1
fi

# Étape 2 : Compiler le fichier kernel.c
echo "Compilation de kernel.c..."
gcc -m32 -c kernel.c -o kernel_c.o -ffreestanding
if [ $? -ne 0 ]; then
    echo "Erreur : Problème avec la compilation de kernel.c"
    exit 1
fi

# Étape 3 : Lier les fichiers avec le script de liaison
echo "Liaison des fichiers..."
ld -m elf_i386 -T link.ld -o kernel.bin kernel_asm.o kernel_c.o
if [ $? -ne 0 ]; then
    echo "Erreur : Problème avec la liaison des fichiers"
    exit 1
fi

# Étape 4 : Lancer QEMU avec le kernel
echo "Lancement de QEMU..."
qemu-system-i386 -kernel kernel.bin 
