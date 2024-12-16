#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64
#define IDT_SIZE 256

// Adresse de la mémoire vidéo
char *vidptr = (char*)0xb8000;
unsigned int current_loc = 0; // Position actuelle sur l'écran

// Tableau de mappage clavier AZERTY
unsigned char keyboard_map[128] = {
    0,  27, '&', 0, '"', '\'', '(', '-', 232, '_', 231, 224, ')', '=', 0, '\t', 
    'a', 'z', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '^', '$', '\n', 0, 'q', 
    's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 249, '*', 0, '<', 'w', 'x', 
    'c', 'v', 'b', 'n', ',', ';', ':', '!', 0, 0, 0, ' ', 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

// Définition d'une entrée IDT
struct IDT_entry {
    unsigned short int offset_lowerbits;
    unsigned short int selector;
    unsigned char zero;
    unsigned char type_attr;
    unsigned short int offset_higherbits;
};

// Tableau IDT
struct IDT_entry IDT[IDT_SIZE];

// Fonction pour écrire dans un port I/O
void write_port(unsigned short port, unsigned char data) {
    asm volatile ("outb %1, %0" : : "dN"(port), "a"(data));
}

// Fonction pour lire un port I/O
unsigned char read_port(unsigned short port) {
    unsigned char result;
    asm volatile ("inb %1, %0" : "=a"(result) : "dN"(port));
    return result;
}

// Charger l'IDT
void load_idt(unsigned long *idt_ptr) {
    asm volatile ("lidt (%0)" : : "r"(idt_ptr));
    asm volatile ("sti"); // Activer les interruptions
}

// Fonction principale du clavier
void keyboard_handler_main(void) {
    unsigned char status;
    char keycode;

    // Signal de fin d'interruption (EOI)
    write_port(0x20, 0x20);

    // Vérifie si une touche a été pressée
    status = read_port(KEYBOARD_STATUS_PORT);
    if (status & 0x01) {
        keycode = read_port(KEYBOARD_DATA_PORT); // Lit le scancode
        if (keycode < 0 || keycode >= 128) return; // Vérifie les limites

        // Affiche le caractère à l'écran si mappé
        if (keyboard_map[keycode] != 0) {
            vidptr[current_loc++] = keyboard_map[keycode];
            vidptr[current_loc++] = 0x07; // Couleur : gris clair sur fond noir
        }
    }
}

// Initialisation de l'IDT
void idt_init(void) {
    unsigned long keyboard_address = (unsigned long)keyboard_handler_main;
    unsigned long idt_address;
    unsigned long idt_ptr[2];

    // Entrée IDT pour l'interruption 0x21 (clavier)
    IDT[0x21].offset_lowerbits = keyboard_address & 0xFFFF;
    IDT[0x21].selector = 0x08; // Segment de code (défini par GRUB)
    IDT[0x21].zero = 0;
    IDT[0x21].type_attr = 0x8E; // Porte d'interruption
    IDT[0x21].offset_higherbits = (keyboard_address >> 16) & 0xFFFF;

    // Adresse et taille de l'IDT
    idt_address = (unsigned long)IDT;
    idt_ptr[0] = (sizeof(struct IDT_entry) * IDT_SIZE) + ((idt_address & 0xFFFF) << 16);
    idt_ptr[1] = idt_address >> 16;

    // Charger l'IDT
    load_idt(idt_ptr);
}

// Activer l'interruption clavier (IRQ1)
void kb_init(void) {
    write_port(0x21, 0xFD); // Activer uniquement IRQ1 (11111101 en binaire)
}

// Fonction `kmain` (point de départ du noyau)
void kmain(void) {
    const char *str = "Mon Premier Kernel";
    unsigned int i = 0;

    // Efface l'écran
    for (i = 0; i < 80 * 25 * 2; i += 2) {
        vidptr[i] = ' ';      // Espace
        vidptr[i + 1] = 0x07; // Couleur
    }

    // Affiche le message initial
    i = 0;
    while (str[i] != '\0') {
        vidptr[current_loc++] = str[i++];
        vidptr[current_loc++] = 0x07; // Couleur
    }

    // Initialiser l'IDT et le clavier
    idt_init();
    kb_init();

    // Boucle infinie
    while (1);
}
