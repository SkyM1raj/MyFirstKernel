;;kernel.asm
;nasm directive - 32 bit

bits 32
section .text

global start
extern kmain
extern keyboard_handler_main ; fonction géant le clavier dans le kernel.c

;spécification Multiboot (Multiboot header) pour que GRUB puisse charger notre kernel
;GRUB charge le kernel en lisant le header multiboot en le chargant en mémoire  à une adresse prédéfinie
;(0x100000) puis transfére le controle a son point d'entrée défini (start)

align 8                                    ;Apparemment c'est recommandé 8 octets
dd 0x1BADB002            ; Magic number    ;Pour pouvoir identifier le header
dd 0x00                  ; Flags           ;doooon't care, pas utilisé ici
dd -(0x1BADB002 + 0x00)  ; Checksum        ;A ce que j'ai compris, c'est une somme de controle qui vérifie que le header
;est valide pour GRUB. GRUB additionne les 3 champs, (le magicnumber, les flags, et le checksum), la somme doit etre égale a Zéro !
;Pourquoi 0 ? Car il est utilisé pour vérifier l'intégrité du header, si le résultat est égal à 0 cela garantit que le header a été 
;correctement et n'est pas corrompu


start:
  cli                   ; Désactive les interruptions   
;Le CPU peut recevoir des interruptions externes pendant son démarrage.
;Ces interruptions sont désactivées temporairement pour éviter des erreurs avant que tout soit prêt.

  mov esp, stack_space  ; Initialise le pointeur de pile,Le registre ESP, c'est le Stack Pointer, il doit pointer apparemment 
						; vers un espace mémoire réservé pour la pile dans la section (.bss) Ca permet au noyau de gérer les appels de fonction en C
  call kmain            ; Appelle la fonction principale du noyau en C (Le fichier kernel)
  hlt                   ; Met le CPU en pause en attendant une interrution ou un redémarrage


section .bss
resb 8192               ; Alloue 8 Ko pour la pile,c'est selon la doc une taille typique pour un noyau minimal
stack_space:

read_port:
	mov edx, [esp + 4]    ; Récupère le numéro de port depuis la pile
	in al, dx             ; Lit une valeur depuis le port spécifié
	ret                   ; Retourne la valeur (dans `al`, donc dans `eax`)
;Permet de lire dans des ports I/O (comme les ports du clavier), lire les données des ports des scancodes du clavier via le port 0X60


write_port:
	mov edx, [esp + 4]        ; Récupère le numéro de port depuis la pile
	mov al, [esp + 4 + 4]     ; Récupère la donnée à écrire depuis la pile
	out dx, al                ; Écrit la donnée dans le port spécifié
	ret
;Permet d'écrire dans des ports I/O (comme les ports du clavier), envoyer des commandes à des ports pour configurer le PIC


load_idt:
	mov edx, [esp + 4]    ; Récupère l’adresse de l’IDT depuis la pile
	lidt [edx]            ; Charge l’IDT dans le processeur
	sti                   ; Active les interruptions
	ret
;L'instruction lidt informe le processeur de l'adresse et de la taille de la table IDT qui est essentielle pour gérer les interruptions
;comme celles du clavier, aprés avoir configuré l'IDT, on peut réactiver les interruptions avec sti


keyboard_handler:
	call keyboard_handler_main ; Appelle la fonction C qui gère l’interruption (lecture du port clavier, affichage de la touche)
	iretd                      ; Retourne du mode interruption, restaure l'état du processeur (registre EIP, flags, etc.) et retourne 
	                           ;à l’instruction interrompue. 




;PS: Je sais qu'il y'a trop de commentaire, mais je savais pas ou les mettre, je les enleverais quand j'aurais maitrisé
;l'arcane du dévellopement logiciel parfaitement... Ben quoi ? J'ai le droit de réver non ?