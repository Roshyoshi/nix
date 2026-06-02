{ lib, pkgs }:

{
  env = {
    TERM = "xterm-256color";
  };

  terminal = {
    shell = {
      program = "${pkgs.zsh}/bin/zsh";
      args = [
        "-lc"
        "exec ${pkgs.tmux}/bin/tmux new-session -A -s main"
      ];
    };
  };

  window = {
    padding = {
      x = 10;
      y = 8;
    };
    dynamic_padding = true;
    decorations = "full";
    opacity = 1.0;
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    option_as_alt = "Both";
  };

  font = {
    size = 13.0;
    normal = {
      family = "JetBrainsMono NFM";
      style = "Regular";
    };
    bold = {
      family = "JetBrainsMono NFM";
      style = "Bold";
    };
    italic = {
      family = "JetBrainsMono NFM";
      style = "Italic";
    };
    bold_italic = {
      family = "JetBrainsMono NFM";
      style = "Bold Italic";
    };
    offset = {
      x = 0;
      y = 1;
    };
  };

  cursor = {
    style = {
      shape = "Beam";
      blinking = "On";
    };
  };

  colors = {
    primary = {
      background = "#1c1408";
      foreground = "#5b8512";
      dim_foreground = "#4f7410";
      bright_foreground = "#7cb518";
    };

    cursor = {
      text = "#1c1408";
      cursor = "#ffbf00";
    };

    vi_mode_cursor = {
      text = "#1c1408";
      cursor = "#ff7000";
    };

    selection = {
      text = "#dfdfdf";
      background = "#26380a";
    };

    normal = {
      black = "#181107";
      red = "#ff4e00";
      green = "#7cb518";
      yellow = "#ffbf00";
      blue = "#0075c4";
      magenta = "#d72638";
      cyan = "#898989";
      white = "#95836f";
    };

    bright = {
      black = "#3f444a";
      red = "#ff7000";
      green = "#5b8512";
      yellow = "#dbc077";
      blue = "#0060a1";
      magenta = "#76597b";
      cyan = "#707a6a";
      white = "#dfdfdf";
    };
  };
}
