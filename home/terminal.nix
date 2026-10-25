# Terminal: fastfetch (logo + specs + recursos) y prompt starship, con los colores del tema.
{ config, lib, ... }:

let
  c = config.lib.stylix.colors;
  # fastfetch acepta secuencias ANSI: color de 24 bits a partir del hex del tema
  ansi = hex: "38;2;${toString (lib.fromHexString (builtins.substring 0 2 hex))};${toString (lib.fromHexString (builtins.substring 2 2 hex))};${toString (lib.fromHexString (builtins.substring 4 2 hex))}";
  key = icono: texto: "${icono}  ${texto}";
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = { top = 1; left = 1; right = 2; };
        color = {
          "1" = ansi c.base0D;
          "2" = ansi c.base0C;
        };
      };

      display = {
        separator = "  ";
        color = {
          keys = ansi c.base0D;
          title = ansi c.base0E;
          output = ansi c.base05;
        };
        percent = {
          type = 3; # número + barra
          color = {
            green = ansi c.base0B;
            yellow = ansi c.base0A;
            red = ansi c.base08;
          };
        };
        bar = {
          width = 8;
          char = { elapsed = "■"; total = "·"; };
        };
        key.width = 15;
        size = {
          binaryPrefix = "jedec";
          ndigits = 1;
        };
      };

      modules = [
        "title"
        { type = "custom"; format = "{#${ansi c.base03}}──────────────────────────────"; }
        { type = "os"; key = key "󱄅" "Sistema"; }
        { type = "kernel"; key = key "󰌽" "Kernel"; }
        { type = "uptime"; key = key "󰅐" "Encendido"; }
        { type = "packages"; key = key "󰏖" "Paquetes"; }
        { type = "wm"; key = key "󰖯" "Escritorio"; }
        { type = "shell"; key = key "󰆍" "Shell"; }
        { type = "terminal"; key = key "󰞷" "Terminal"; }
        { type = "command"; key = key "󰏘" "Tema"; text = "cat /var/lib/tema 2>/dev/null || echo nord"; }
        { type = "custom"; format = "{#${ansi c.base03}}──────────────────────────────"; }
        { type = "cpu"; key = key "󰻠" "CPU"; showPeCoreCount = true; }
        { type = "cpuusage"; key = key "󰻠" "Uso CPU"; }
        { type = "gpu"; key = key "󰢮" "GPU"; }
        { type = "memory"; key = key "󰍛" "Memoria"; }
        { type = "swap"; key = key "󰒯" "Swap"; }
        { type = "disk"; key = key "󰋊" "Disco"; folders = "/"; }
        { type = "battery"; key = key "󰁹" "Batería"; }
        { type = "command"; key = key "󰓅" "Energía"; text = "powerprofilesctl get 2>/dev/null || echo -"; }
        { type = "localip"; key = key "󰩠" "IP"; }
        "break"
        { type = "colors"; symbol = "circle"; paddingLeft = 2; }
      ];
    };
  };

  # Mostrar fastfetch al abrir la terminal (solo en el primer shell, no en los anidados)
  programs.bash.initExtra = ''
    if [[ $- == *i* && -z "$FASTFETCH_SHOWN" ]]; then
      export FASTFETCH_SHOWN=1
      fastfetch
    fi
  '';

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";
      directory = {
        style = "bold #${c.base0D}";
        truncation_length = 3;
        read_only = " 󰌾";
      };
      git_branch = {
        symbol = "󰘬 ";
        style = "#${c.base0E}";
        format = "[$symbol$branch]($style) ";
      };
      git_status.style = "#${c.base0A}";
      nix_shell = {
        symbol = "󱄅 ";
        style = "#${c.base0C}";
        format = "[$symbol$state]($style) ";
      };
      cmd_duration = {
        min_time = 2000;
        style = "#${c.base03}";
        format = "[󰥔 $duration]($style) ";
      };
      character = {
        success_symbol = "[❯](bold #${c.base0D})";
        error_symbol = "[❯](bold #${c.base08})";
      };
    };
  };
}
