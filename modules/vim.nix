{ pkgs, ... }:

{
  programs.vim = {
    enable = true;

    # Built-in Home Manager settings mapping
    settings = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
      ignorecase = true;
    };

    # Essential lightweight plugins
    plugins = with pkgs.vimPlugins; [
      vim-airline # Provides a clean status bar at the bottom
      vim-surround # Easily change/add/delete surrounding quotes or brackets
      vim-commentary # Use 'gc' to instantly comment out lines or blocks of code
      vim-tmux-navigator
    ];

    # Raw vimrc configuration for settings Home Manager doesn't natively abstract
    extraConfig = ''
      " Yank and Paste with the system clipboard
      set clipboard=unnamedplus

      " Enable syntax highlighting
      syntax on

      " Search Improvements
      set smartcase     " Automatically switch to case-sensitive if you type a capital letter
      set incsearch     " Highlight search matches as you type them
      set hlsearch      " Keep search matches highlighted after pressing enter
      
      " Clear search highlighting on pressing Escape
      nnoremap <Esc> :noh<CR><Esc>

      " Editor UI & Behavior
      set autoindent    " Copy indent from current line when starting a new line
      set smartindent   " Automatically insert an extra level of indentation in some cases (e.g. after '{')
      set cursorline    " Highlight the line the cursor is currently on
      set scrolloff=8   " Keep 8 lines of context visible above and below the cursor when scrolling
      set mouse=a       " Allow mouse usage for scrolling and pane resizing
      
      " Performance/UX
      set updatetime=300 " Faster update time (default is 4000ms) for smoother plugin behavior
      set signcolumn=yes " Always draw the sign column to prevent text shifting when errors/git signs appear
    '';
  };
}
