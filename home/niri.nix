# Configuración de niri. Los colores salen de Stylix para seguir el tema global.
{ config, pkgs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;

  # Mod+P: rota ahorro → balanceado → rendimiento
  cyclePower = pkgs.writeShellScript "cycle-power-profile" ''
    case "$(powerprofilesctl get)" in
      power-saver) next=balanced ;;
      balanced) next=performance ;;
      *) next=power-saver ;;
    esac
    powerprofilesctl set "$next"
    notify-send -t 1500 "Perfil de energía" "$next"
  '';
in
{
  home.packages = with pkgs; [ libnotify ];

  # Fondo de pantalla (la imagen la define Stylix)
  systemd.user.services.swaybg = {
    Unit = {
      Description = "Fondo de pantalla";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i ${config.stylix.image}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "latam"
            }
            numlock
        }
        touchpad {
            tap
            natural-scroll
            dwt
        }
        focus-follows-mouse max-scroll-amount="0%"
    }

    layout {
        gaps 8
        center-focused-column "never"
        background-color "${c.base00}"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }
        default-column-width { proportion 0.5; }

        focus-ring {
            width 2
            active-color "${c.base0D}"
            inactive-color "${c.base03}"
        }
        border { off; }
    }

    prefer-no-csd
    screenshot-path "~/Imágenes/Capturas/%Y-%m-%d_%H-%M-%S.png"

    hotkey-overlay {
        skip-at-startup
    }

    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        Mod+Return hotkey-overlay-title="Terminal" { spawn "foot"; }
        Mod+D hotkey-overlay-title="Lanzador" { spawn "fuzzel"; }
        Mod+B hotkey-overlay-title="Navegador" { spawn "brave"; }
        Mod+E hotkey-overlay-title="Archivos" { spawn "nautilus"; }
        Super+Alt+L hotkey-overlay-title="Bloquear" { spawn "hyprlock"; }
        Mod+P hotkey-overlay-title="Perfil de energía" { spawn "${cyclePower}"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
        XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
        XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
        XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Q { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-or-workspace-up; }
        Mod+Down  { focus-window-or-workspace-down; }
        Mod+H     { focus-column-left; }
        Mod+L     { focus-column-right; }
        Mod+K     { focus-window-or-workspace-up; }
        Mod+J     { focus-window-or-workspace-down; }

        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+Up    { move-window-up-or-to-workspace-up; }
        Mod+Ctrl+Down  { move-window-down-or-to-workspace-down; }
        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+L     { move-column-right; }
        Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }
        Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }

        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft  { focus-column-left; }
        Mod+Shift+WheelScrollDown { focus-column-right; }
        Mod+Shift+WheelScrollUp   { focus-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        Mod+Comma  { consume-or-expel-window-left; }
        Mod+Period { consume-or-expel-window-right; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-column; }
        Mod+V { toggle-window-floating; }
        Mod+W { toggle-column-tabbed-display; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Plus  { set-column-width "+10%"; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }
    }
  '';
}
