# NixOS de peppi

Configuración reproducible (flake) para la **ThinkPad E14 Gen 4** (i5-1235U, Iris Xe, 16 GB) y su VM de pruebas.
Escritorio **niri** con Waybar, fuzzel, ReGreet y hyprlock; tres temas intercambiables (Nord, Monocromo, Fresco)
sobre un fondo ASCII de *La creación de Adán*.

```
flake.nix               hosts: vm (libvirt) y laptop
hosts/laptop/           ThinkPad: arranque XBOOTLDR, firmware, thermald
hosts/vm/               VM de pruebas en el escritorio
modules/                base, btrfs, escritorio, apps, temas, juegos
home/                   Home Manager: niri, Waybar, terminal, bloqueo
wallpapers/             fondos por tema (generados con tools/ascii-wallpaper.py)
tools/                  deploy a la VM, generador de fondos, teclado virtual
```

---

## Instalación en la laptop (junto a Windows y Fedora)

Toma ~1 hora, la mayor parte es descarga. Hazlo enchufado y con Wi-Fi estable.

### 0. Antes de empezar (desde Windows o Fedora)

1. **Respaldo** de lo importante.
2. **Clave de recuperación de BitLocker.** Al desactivar Secure Boot, Windows puede pedirla en el siguiente arranque.
   Búscala en <https://account.microsoft.com/devices/recoverykey> y anótala **antes** de seguir.
3. **Liberar espacio:** en Windows, *Administración de discos* → clic derecho en `C:` → *Reducir volumen*.
   Deja al menos **100 GB sin asignar** (no crees particiones ahí, la guía lo hace).
4. **USB de instalación:** descarga la ISO *minimal* de NixOS 26.05 (<https://nixos.org/download>) y grábala con
   Fedora Media Writer, Ventoy o `dd`.
5. **BIOS** (F1 al encender): *Security → Secure Boot → Off*. Guarda con F10.

### 1. Arrancar el USB

Enciende con **F12** y elige el USB. Al llegar a la consola:

```bash
sudo -i
nmtui                      # Wi-Fi: "Activate a connection"
loadkeys la-latin1         # teclado latinoamericano
lsblk -f                   # identifica el disco (normalmente nvme0n1) y la ESP de Windows (vfat, 100-260 MB)
```

Anota el nombre de la **ESP de Windows** (p. ej. `/dev/nvme0n1p1`).

### 2. Particionar el espacio libre

Crea dos particiones en el espacio sin asignar: 1 GB para el arranque de NixOS y el resto cifrado.
(`0` como inicio usa el bloque libre más grande, es decir, el que liberaste en Windows.)

```bash
DISCO=/dev/nvme0n1
sgdisk -n 0:0:+1G -t 0:ea00 -c 0:nixos-boot  $DISCO
sgdisk -n 0:0:0   -t 0:8309 -c 0:nixos-crypt $DISCO
partprobe $DISCO
lsblk -f $DISCO            # verifica: Windows y Fedora intactos, dos particiones nuevas
```

### 3. Formatear y cifrar

Aquí eliges **tu contraseña de cifrado** (se pide en cada arranque):

```bash
mkfs.vfat -F32 -n NIXBOOT /dev/disk/by-partlabel/nixos-boot
cryptsetup luksFormat --type luks2 /dev/disk/by-partlabel/nixos-crypt
cryptsetup open --allow-discards /dev/disk/by-partlabel/nixos-crypt cryptroot

mkfs.btrfs -L nixos /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
for s in @ @home @nix @log; do btrfs subvolume create /mnt/$s; done
umount /mnt

O=compress=zstd:1,noatime
mount -o subvol=@,$O     /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{home,nix,var/log,boot,efi}
mount -o subvol=@home,$O /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,$O  /dev/mapper/cryptroot /mnt/nix
mount -o subvol=@log,$O  /dev/mapper/cryptroot /mnt/var/log
mount -o umask=0077 /dev/disk/by-partlabel/nixos-boot /mnt/boot
mount -o umask=0077 /dev/nvme0n1p1 /mnt/efi          # ← la ESP de Windows que anotaste
```

### 4. Traer esta configuración

```bash
mkdir -p /mnt/home/peppi
git clone <URL-del-repo> /mnt/home/peppi/nixos-config
# Alternativa sin internet: copiar la carpeta desde un segundo USB.
cd /mnt/home/peppi/nixos-config

# Hardware real de la laptop (reemplaza el archivo provisorio)
nixos-generate-config --root /mnt --show-hardware-config > hosts/laptop/hardware-configuration.nix
grep -E '"/"|/boot|/efi|luks' hosts/laptop/hardware-configuration.nix   # deben aparecer los cuatro
git add -A                 # los flakes solo ven archivos registrados en git
```

### 5. Instalar

```bash
nixos-install --impure --flake .#laptop --no-root-passwd
nixos-enter --root /mnt -c 'passwd peppi'                         # tu contraseña de usuario
nixos-enter --root /mnt -c 'chown -R peppi:users /home/peppi'
reboot                                                             # y saca el USB
```

### 6. Primer arranque

- Menú de arranque: **NixOS** (tema guardado), entradas extra por cada tema y **Windows Boot Manager**.
  **Fedora** se elige con **F12**. Si NixOS no aparece primero, en la BIOS pon *Linux Boot Manager* arriba.
- Contraseña del disco → pantalla de login → **Niri** ya viene elegido.
- Pendientes manuales:
  ```bash
  sudo tailscale up                       # conectar a tu tailnet
  # Syncthing: abre http://127.0.0.1:8384, agrega el escritorio y comparte la bóveda de Obsidian
  # Moonlight: emparejar con Sunshine del escritorio
  # Deska: descargar la AppImage, chmod +x y abrirla
  cd ~/nixos-config && git commit -am "laptop: hardware real" && git push
  ```

---

## Uso diario

| Atajo | Acción |
|---|---|
| Super + Enter | Terminal |
| Super + D | Lanzador |
| Super + B | Brave |
| Super + E | Archivos |
| Super + Q | Cerrar ventana |
| Super + ← → / H L | Moverse entre columnas |
| Super + ↑ ↓ / K J | Ventana o escritorio arriba/abajo |
| Super + Ctrl + flechas | Mover columna/ventana |
| Super + 1…9 | Ir a escritorio |
| Super + R / F | Ancho de columna / maximizar |
| Super + O | Vista general |
| Super + T | Cambiar tema |
| Super + P | Rotar perfil de energía |
| Super + Alt + L | Bloquear |
| Super + Shift + / | Todos los atajos |
| Impr / Ctrl+Impr / Alt+Impr | Captura (área / pantalla / ventana) |

**Comandos**

```bash
tema                 # menú de temas (también Super+T)
rebuild              # aplicar cambios hechos en ~/nixos-config
actualizar           # actualizar todo el sistema (nix flake update + rebuild)
```

- Cada `rebuild` crea una **generación**: si algo falla, elige la anterior en el menú de arranque.
- El tema base sale de `/var/lib/tema`; por eso los rebuild llevan `--impure` (los atajos ya lo incluyen).
- Juegos: en Steam, *Propiedades → Opciones de lanzamiento*:
  `gamemoderun %command%` o, para más FPS en la Iris Xe,
  `gamescope -w 1280 -h 720 -W 1920 -H 1080 -F fsr -- gamemoderun %command%`.

## Si más adelante borras Windows y Fedora

1. Borra sus particiones (no toques la ESP mientras sea la única: ahí vive systemd-boot).
2. Para aprovechar el espacio sin mover particiones: crea una partición nueva con ese espacio, ábrela con LUKS
   y súmala al mismo btrfs con `btrfs device add /dev/mapper/<nombre> /` (y agrégala a `hardware-configuration.nix`).
3. Si algún día eliminas la ESP de Windows, crea una nueva de 512 MB montada en `/efi` y corre `rebuild`.

## Desarrollo en la VM

```bash
tools/deploy-vm.sh build    # compila en la VM sin aplicar
tools/deploy-vm.sh switch   # compila y aplica
```

Fondos: `tools/ascii-wallpaper.py <imagen> <salida.png> [--colorize] [--fg #hex --bg #hex] [--center-y 0.27]`.
