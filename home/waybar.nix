# Barra superior. Colores y fuente los pone Stylix.
{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 6;

      modules-left = [ "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "power-profiles-daemon"
        "pulseaudio"
        "backlight"
        "network"
        "battery"
      ];

      "niri/window" = {
        max-length = 50;
      };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
        locale = "es_CL.UTF-8";
      };

      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = "Perfil: {profile}";
        format-icons = {
          default = "󰾅";
          performance = "󰓅";
          balanced = "󰾅";
          power-saver = "󰾆";
        };
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "pavucontrol";
      };

      backlight = {
        format = "󰃟 {percent}%";
      };

      network = {
        format-wifi = "󰤨 {essid}";
        format-ethernet = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format = "{ifname} {ipaddr}";
      };

      battery = {
        states = {
          warning = 25;
          critical = 10;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
      };

      tray.spacing = 8;
    };
  };
}
