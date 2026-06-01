{ pkgs, ... }:

let
  tmuxGitStatus = pkgs.writeShellScriptBin "tmux-git-status" ''
    set -eu

    path="''${1:-$PWD}"

    if ! ${pkgs.git}/bin/git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      exit 0
    fi

    root="$(${pkgs.git}/bin/git -C "$path" rev-parse --show-toplevel 2>/dev/null || true)"
    branch="$(${pkgs.git}/bin/git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || ${pkgs.git}/bin/git -C "$path" rev-parse --short HEAD 2>/dev/null || true)"

    if [ -z "$root" ]; then
      exit 0
    fi

    dirty=""
    if [ -n "$(${pkgs.git}/bin/git -C "$path" status --porcelain --ignore-submodules=dirty 2>/dev/null)" ]; then
      dirty="*"
    fi

    repo="$(${pkgs.coreutils}/bin/basename "$root")"

    if [ -n "$branch" ]; then
      printf ' %s %s%s ' "$repo" "$branch" "$dirty"
    else
      printf ' %s ' "$repo"
    fi
  '';
in
{
  programs.tmux = {
    enable = true;
    shortcut = "b";
    baseIndex = 1;
    clock24 = true;

    # Enables vi-style navigation in copy mode
    keyMode = "vi";

    # Installs the tmux-yank plugin for macOS clipboard integration
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      set -g mouse on
      set -g status-keys vi
      set-option -g status-position top
      setw -g mode-keys vi
      setw -g automatic-rename on
      set -g renumber-windows on

      # Status line
      set -g status on
      set -g status-interval 5
      set -g status-left-length 80
      set -g status-right-length 120
      set -g status-style "bg=#17120e,fg=#ffe0bd"
      set -g status-left "#[fg=#17120e,bg=#ff9e64,bold] #S #[fg=#ff9e64,bg=#2a1b12]#[fg=#ffe0bd,bg=#2a1b12] #I:#P #[fg=#2a1b12,bg=#17120e] "
      set -g status-right "#[fg=#17120e,bg=#ff9e64,bold]#(${tmuxGitStatus}/bin/tmux-git-status \"#{pane_current_path}\")#[fg=#ffb86b,bg=#17120e] %Y-%m-%d #[fg=#17120e,bg=#ff9e64,bold] %H:%M "
      set -g window-status-format "#[fg=#ffb86b,bg=#17120e] #I:#W "
      set -g window-status-current-format "#[fg=#17120e,bg=#ff9e64,bold] #I:#W#{?window_zoomed_flag, Z,} "
      set -g pane-border-style "fg=#4a3124"
      set -g pane-active-border-style "fg=#ff9e64"
      set -g message-style "bg=#ff9e64,fg=#17120e,bold"
      set -g mode-style "bg=#ffb86b,fg=#17120e,bold"

      # Vim-like visual selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Vim-like pane switching
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R
    '';
  };
}
