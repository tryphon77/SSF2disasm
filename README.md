# SSF2disasm
 WIP: Python scripts, ghidra files, to disassemble Megadrive Super Street Fighter II

Quelques scripts pour obtenir un désassemblage parfait de Super Street Fighter II

Les buts sont :
* des fichiers asm modifiables qui se compilent pour donner un jeu jouable
* l'extraction de toutes les données du jeu

À terme, pouvoir éditer le jeu (niveaux, personnages) et le transformer en Super Street Fighter II Turbo, ou Hyper.

Fichiers utiles :
disasm.py : script principal, génère le désassemblage
buffer_alt.py : classe Buffer utilisé pour le désassemblage (buffer.py sert à autre chose, il faudra les fusionner)
m68k_alt.py : désassembleur 68000
data.py : contient les classes Label, Data, et les instances de Type (qui permet de désassembler des données structurées)

Autres :
dump, dump_anim, make_frame_sheet : pour dumper certaines assets (devrait fusionner avec data)
gfx : classes Surface4bpp et VDP pour faciliter l'extraction de données
patch : pour créer des versions patchées du jeu (avec vie infinie / le débug test mode / etc.)

fichiers .bytes et répertoire ssf2.rep : fichiers ghidra