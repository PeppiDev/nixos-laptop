# Barra superior en "islas" flotantes. Colores de Stylix, estilo propio.
{ config, pkgs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;

  # Menú de energía con fuzzel en modo dmenu
  powerMenu = pkgs.writeShellScript "power-menu" ''
    choice=$(printf '%s\n' \
      "󰌾  Bloquear" \
      "󰤄  Suspender" \
      "󰍃  Cerrar sesión" \
      "󰜉  Reiniciar" \
      "󰐥  Apagar" | fuzzel --dmenu --prompt "󰐥  " --lines 5 --width 22)
    case "$choice" in
      *Bloquear) loginctl lock-session ;;
      *Suspender) systemctl suspend ;;
      *Cerrar*) niri msg action quit --skip-confirmation ;;
      *Reiniciar) systemctl reboot ;;
      *Apagar) systemctl poweroff ;;
    esac
  '';
in
{
  # Usamos CSS propio en vez del de Stylix
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 30;
      margin-top = 6;
      margin-left = 8;
      margin-right = 8;
      spacing = 0;

      modules-left = [ "custom/launcher" "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "custom/tema"
        "cpu"
        "memory"
        "tray"
        "power-profiles-daemon"
        "bluetooth"
        "network"
        "pulseaudio"
        "backlight"
        "battery"
        "custom/power"
      ];

      "custom/launcher" = {
        format = "󱄅";
        tooltip = false;
        on-click = "fuzzel";
      };

      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          active = "󰝥";
          default = "󰝦";
        };
      };

      "niri/window" = {
        format = "{title}";
        max-length = 45;
        separate-outputs = true;
      };

      clock = {
        format = "{:L%a %d %b  %H:%M}";
        format-alt = "{:L%A %d de %B de %Y}";
        locale = "es_CL.UTF-8";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          weeks-pos = "";
          format = {
            months = "<span color='${c.base0D}'><b>{}</b></span>";
            weekdays = "<span color='${c.base0A}'><b>{}</b></span>";
            today = "<span color='${c.base08}'><b><u>{}</u></b></span>";
          };
        };
      };

      cpu = {
        format = "󰻠 {usage}%";
        interval = 5;
        tooltip = false;
      };

      memory = {
        format = "󰍛 {used:0.1f}G";
        interval = 5;
        tooltip-format = "{used:0.1f} / {total:0.1f} GB";
      };

      tray = {
        icon-size = 15;
        spacing = 8;
      };

      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = "Perfil: {profile}";
        format-icons = {
          default = "󰗑";
          performance = "󰓅";
          balanced = "󰗑";
          power-saver = "󰌪";
        };
      };

      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-off = "󰂲";
        format-connected = "󰂱 {num_connections}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}";
        on-click = "blueman-manager";
      };

      network = {
        format-wifi = "{icon}";
        format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        format-ethernet = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}";
        on-click = "nm-connection-editor";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "pavucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [ "󰃞" "󰃟" "󰃠" ];
      };

      battery = {
        states = {
          warning = 25;
          critical = 10;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        tooltip-format = "{timeTo}";
      };

      "custom/tema" = {
        format = "󰏘";
        tooltip-format = "Cambiar tema";
        on-click = "tema";
      };

      "custom/power" = {
        format = "󰐥";
        tooltip = false;
        on-click = "${powerMenu}";
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background: transparent;
        color: ${c.base05};
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: alpha(${c.base00}, ${toString config.stylix.opacity.desktop});
        border: 1px solid ${c.base02};
        border-radius: 10px;
        padding: 0 4px;
      }

      #custom-launcher {
        color: ${c.base0D};
        font-size: 16px;
        padding: 0 10px 0 8px;
      }

      #workspaces button {
        color: ${c.base03};
        padding: 0 5px;
        background: transparent;
        border-radius: 6px;
      }
      #workspaces button.active {
        color: ${c.base0D};
      }
      #workspaces button:hover {
        background: ${c.base01};
        color: ${c.base05};
      }

      #window {
        color: ${c.base04};
        padding: 0 8px;
      }

      #clock {
        color: ${c.base06};
        font-weight: bold;
        padding: 0 12px;
      }

      #cpu, #memory, #tray, #power-profiles-daemon, #bluetooth,
      #network, #pulseaudio, #backlight, #battery, #custom-power {
        padding: 0 8px;
      }

      #custom-tema { color: ${c.base0E}; padding: 0 8px; }
      #cpu { color: ${c.base0C}; }
      #memory { color: ${c.base0E}; }
      #power-profiles-daemon { color: ${c.base0B}; }
      #power-profiles-daemon.performance { color: ${c.base08}; }
      #power-profiles-daemon.power-saver { color: ${c.base0A}; }
      #bluetooth { color: ${c.base0D}; }
      #network { color: ${c.base0C}; }
      #network.disconnected { color: ${c.base03}; }
      #pulseaudio { color: ${c.base0D}; }
      #pulseaudio.muted { color: ${c.base03}; }
      #backlight { color: ${c.base0A}; }
      #battery { color: ${c.base0B}; }
      #battery.warning:not(.charging) { color: ${c.base0A}; }
      #battery.critical:not(.charging) { color: ${c.base08}; }

      #custom-power {
        color: ${c.base08};
        padding-right: 10px;
      }

      tooltip {
        background: ${c.base00};
        border: 1px solid ${c.base02};
        border-radius: 8px;
      }
    '';
  };
}
