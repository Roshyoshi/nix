{
  config,
  lib,
  pkgs,
  ...
}:

let
  alacrittySettings = import ./alacritty-settings.nix { inherit lib pkgs; };
in
{
  # Install standard binaries
  home.packages =
    with pkgs;
    [
      (lib.hiPrio codex)
      fd
      ripgrep
      cargo
      clippy
      rust-analyzer
      rustc
      rustfmt
      stow
      typst
      wget
      gemini-cli
      nerd-fonts.jetbrains-mono
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      wl-clipboard
      xclip
    ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.file.".cargo/config.toml" = {
    force = true;
    text = ''
      [net]
      git-fetch-with-cli = true
    '';
  };

  home.file.".stow-global-ignore".text = ''
    \.git
    \.gitignore
    README.*
    LICENSE.*
  '';

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  home.activation.installTerminalFonts = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      font_dir="$HOME/Library/Fonts"
      src_dir="${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono"

      $DRY_RUN_CMD /bin/mkdir -p "$font_dir"
      for face in Regular Bold Italic BoldItalic; do
        $DRY_RUN_CMD /bin/rm -f "$font_dir/JetBrainsMonoNerdFontMono-$face.ttf"
        $DRY_RUN_CMD /usr/bin/install -m 0644 "$src_dir/JetBrainsMonoNerdFontMono-$face.ttf" "$font_dir/JetBrainsMonoNerdFontMono-$face.ttf"
      done

      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        /usr/bin/killall fontd >/dev/null 2>&1 || true
      fi
    ''
  );

  home.sessionVariables = {
    ALTERNATE_EDITOR = "";
    EDITOR = "emacsclient -t";
    GIT_EDITOR = "emacsclient -t";
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
    TERMINAL = "${pkgs.alacritty}/bin/alacritty";
    VISUAL = "emacsclient -c";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      # Leave Ctrl-D on zsh's default EOF behavior.
    '';

    shellAliases = {
      dots = "git -C ${config.home.homeDirectory}/.dotfiles";
      stow-dotfiles = "stow --dir=${config.home.homeDirectory}/.dotfiles --target=${config.home.homeDirectory}";
      emacs = "emacs -nw";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = alacrittySettings;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      command_timeout = 1000;
      format = "$directory$hostname$git_branch$git_status$character";
      palette = "manegarm";

      palettes.manegarm = {
        bg = "#1c1408";
        fg = "#5b8512";
        orange = "#ff7000";
        tan = "#dbc077";
        red = "#ff4e00";
        green = "#7cb518";
        yellow = "#ffbf00";
        blue = "#0075c4";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style)";
        style = "bold green";
      };

      directory = {
        style = "bold tan";
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[  $path ]($style)";
      };

      git_branch = {
        symbol = " ";
        style = "bold orange";
        format = "[ $symbol$branch ]($style)";
      };

      git_status = {
        style = "bold yellow";
        format = "([$all_status$ahead_behind ]($style))";
        conflicted = "!";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        up_to_date = "";
        untracked = "?";
        stashed = "$";
        modified = "*";
        staged = "+";
        renamed = "r";
        deleted = "x";
      };

      character = {
        success_symbol = "[ ❯](bold orange)";
        error_symbol = "[x](bold red)";
      };

      time.disabled = true;
    };
  };

  home.file.".envrc".text = ''
    # Trigger direnv evaluation below $HOME; flake loading lives in direnvrc.
    :
  '';

  # Direnv configuration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # Injects direnv hook into ~/.zshrc
    nix-direnv.enable = true; # Highly recommended for faster Nix shell caching
    stdlib = ''
      find_flake_dir_up() {
        local dir="$PWD"

        while [ "$dir" != "/" ]; do
          if [ -f "$dir/flake.nix" ]; then
            printf '%s\n' "$dir"
            return
          fi

          dir="''${dir%/*}"
        done
      }

      flake_dir="$(find_flake_dir_up)"
      if [ -n "$flake_dir" ]; then
        use flake "$flake_dir"
      fi
    '';
  };
}
