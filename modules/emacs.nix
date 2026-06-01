{ config, lib, pkgs, ... }:

let
  oldDoomFiles = [
    ".config/doom/init.el"
    ".config/doom/config.el"
    ".config/doom/packages.el"
  ];
  treeSitterGrammars = {
    javascript = pkgs.tree-sitter-grammars.tree-sitter-javascript;
    jsdoc = pkgs.tree-sitter-grammars.tree-sitter-jsdoc;
    rust = pkgs.tree-sitter-grammars.tree-sitter-rust;
    tsx = pkgs.tree-sitter-grammars.tree-sitter-tsx;
    typescript = pkgs.tree-sitter-grammars.tree-sitter-typescript;
    typst = pkgs.tree-sitter-grammars.tree-sitter-typst;
  };
  linkTreeSitterGrammar = lang: grammar: ''
    for grammar_dir in $grammar_dirs; do
      $DRY_RUN_CMD /bin/ln -sfn "${grammar}/parser" "$grammar_dir/libtree-sitter-${lang}.dylib"
    done
  '';
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };
  services.emacs = {
    enable = true;
    package = config.programs.emacs.finalPackage;
  };

  home.packages = with pkgs; [
    # Doom doctor/runtime tools.
    cmake
    coreutils-prefixed
    fontconfig
    glslang
    gnumake
    nerd-fonts.symbols-only
    nodejs
    pandoc
    shellcheck
    symbola
    tinymist

    # Language support used by the enabled Doom modules.
    cabal-install
    clang
    clang-tools
    ghc
    haskell-language-server
    haskellPackages.hoogle
    nil
    nixfmt
    shfmt
    tree-sitter
    typescript-language-server
  ];

  fonts.fontconfig.enable = true;

  home.activation.installDoomFonts = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    font_dir="$HOME/Library/Fonts"
    symbola_src="${pkgs.symbola}/share/fonts/opentype/Symbola.otf"
    symbols_nerd_src="${pkgs.nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols/SymbolsNerdFontMono-Regular.ttf"

    $DRY_RUN_CMD /bin/mkdir -p "$font_dir"
    $DRY_RUN_CMD /bin/rm -f "$font_dir/Symbola.otf" "$font_dir/SymbolsNerdFontMono-Regular.ttf"
    $DRY_RUN_CMD /usr/bin/install -m 0644 "$symbola_src" "$font_dir/Symbola.otf"
    $DRY_RUN_CMD /usr/bin/install -m 0644 "$symbols_nerd_src" "$font_dir/SymbolsNerdFontMono-Regular.ttf"

    if [ -z "''${DRY_RUN_CMD:-}" ]; then
      /usr/bin/killall fontd >/dev/null 2>&1 || true
    fi
  '';

  home.activation.installDoomTreeSitterGrammars = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    grammar_dirs="$HOME/.config/emacs/.local/etc/tree-sitter $HOME/.config/emacs/.local/etc/@/tree-sitter $HOME/.config/emacs/.local/cache/tree-sitter"
    bin_dir="$HOME/.config/emacs/.local/bin"

    for grammar_dir in $grammar_dirs; do
      $DRY_RUN_CMD /bin/mkdir -p "$grammar_dir"
    done
    $DRY_RUN_CMD /bin/mkdir -p "$bin_dir"
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList linkTreeSitterGrammar treeSitterGrammars)}
    $DRY_RUN_CMD /bin/ln -sfn "${pkgs.tinymist}/bin/tinymist" "$bin_dir/tinymist"
  '';


  home.activation.removeManagedDoomConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for rel in ${lib.concatStringsSep " " (map lib.escapeShellArg oldDoomFiles)}; do
      path="$HOME/$rel"
      if [ -L "$path" ]; then
        target=$(/bin/readlink "$path")
        case "$target" in
          /nix/store/*)
            $DRY_RUN_CMD /bin/rm "$path"
            ;;
        esac
      fi
    done

    doom_dir="$HOME/.config/doom"
    if [ -d "$doom_dir" ] && [ -z "$(/bin/ls -A "$doom_dir")" ]; then
      $DRY_RUN_CMD /bin/rmdir "$doom_dir"
    fi
  '';
}
