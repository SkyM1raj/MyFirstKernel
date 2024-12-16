OUTPUT_FORMAT(elf32-i386)
# Définit le format de sortie du fichier exécutable.
# Ici, le format ELF (Executable and Linkable Format) est utilisé.
# "elf32-i386" spécifie un exécutable 32 bits pour l'architecture x86 (Intel 386).
# Ce format est requis pour que GRUB puisse charger correctement le noyau.

ENTRY(start)
# Définit le point d'entrée du programme.
# "start" est une étiquette définie dans le fichier assembleur (`kernel.asm`).
# C'est l'adresse où GRUB commencera l'exécution après avoir chargé le noyau.

SECTIONS
{
   . = 0x100000;
   # Définit l'adresse de chargement initiale du noyau en mémoire.
   # Ici, l'adresse est fixée à `0x100000` (1 Mo).
   # GRUB charge généralement le noyau à partir de cette adresse pour les systèmes x86.

   .text : { *(.text) }
   # Définit la section `.text` du binaire final.
   # La section `.text` contient tout le code exécutable (assembleur et C).
   # Le symbole `*` signifie "fusionne toutes les sections `.text` des fichiers objets".
   # Ces sections sont placées en premier dans le fichier binaire, à l'adresse actuelle.

   .data : { *(.data) }
   # Définit la section `.data` du binaire final.
   # La section `.data` contient toutes les variables **initialisées** du programme.
   # Exemple : une variable globale comme `int x = 42;` sera placée ici.

   .bss : { *(.bss) }
   # Définit la section `.bss` du binaire final.
   # La section `.bss` contient toutes les variables **non initialisées**.
   # Exemple : une variable globale comme `int y;` sera placée ici.
   # Ces variables seront automatiquement initialisées à zéro au moment de l'exécution.

   # Chaque section (.text, .data, .bss) est fusionnée à partir des fichiers objets
   # et placée en mémoire dans cet ordre précis.
}
