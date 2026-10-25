# Cambio de tema en caliente: `tema` (menú) → `sudo tema-aplicar <nombre>`.
# Activa el specialisation al instante y, en segundo plano, reconstruye para que
# el tema elegido sea el base del próximo arranque (incluida la pantalla de login).
{ config, lib, pkgs, ... }:

let
  lista = lib.concatStringsSep " " config.tema.lista;

  aplicar = pkgs.writeShellScriptBin "tema-aplicar" ''
    set -euo pipefail
    t="''${1:-}"
    case " ${lista} " in
      *" $t "*) ;;
      *) echo "uso: tema-aplicar <${lib.concatStringsSep "|" config.tema.lista}>" >&2; exit 1 ;;
    esac

    echo "$t" > /var/lib/tema

    perfil=/nix/var/nix/profiles/system
    if [ -e "$perfil/specialisation/$t" ]; then
      "$perfil/specialisation/$t/bin/switch-to-configuration" test
    else
      "$perfil/bin/switch-to-configuration" test
    fi

    # Persistir en segundo plano (una sola reconstrucción a la vez)
    systemctl stop tema-persistir.service 2>/dev/null || true
    systemctl reset-failed tema-persistir.service 2>/dev/null || true
    systemd-run --unit=tema-persistir --collect \
      --setenv=PATH=/run/current-system/sw/bin \
      nixos-rebuild boot --impure --flake ${config.tema.flake}
  '';

  menu = pkgs.writeShellScriptBin "tema" ''
    elegido=$(printf '%s\n' "Nord" "Monocromo" "Fresco" \
      | fuzzel --dmenu --prompt "󰏘  " --lines 3 --width 18) || exit 0
    case "$elegido" in
      Nord) t=nord ;;
      Monocromo) t=mono ;;
      Fresco) t=fresco ;;
      *) exit 0 ;;
    esac
    if sudo /run/current-system/sw/bin/tema-aplicar "$t"; then
      notify-send -t 2500 "Tema" "$elegido aplicado"
    else
      notify-send -u critical "Tema" "No se pudo aplicar $elegido"
    fi
  '';
in
{
  options.tema.flake = lib.mkOption {
    type = lib.types.str;
    description = "Flake usado para persistir el tema, p. ej. /home/peppi/nixos-config#vm";
  };

  config = {
    environment.systemPackages = [ aplicar menu ];

    # root reconstruye desde el repo de peppi: git debe confiar en esa carpeta
    programs.git = {
      enable = true;
      config.safe.directory = [ (builtins.head (lib.splitString "#" config.tema.flake)) ];
    };

    security.sudo.extraRules = [
      {
        users = [ "peppi" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/tema-aplicar";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
