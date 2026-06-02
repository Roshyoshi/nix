{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    # Global .gitignore applies to all repositories on your machine
    ignores = [
      ".DS_Store"
      "*.swp"
      "*~"
      ".direnv/"
    ];

    settings = {
      user = {
        name = "Roshan Hegde";
        email = "roshan.hegde@uwaterloo.ca";
      };

      # Automatically set upstream branch tracking when pushing a new branch
      push.autoSetupRemote = true;

      credential.helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "cache";

      core.editor = ''emacsclient -t -a ""'';

      # Modern default branch naming
      init.defaultBranch = "main";

      # Pull behavior (rebase by default keeps history cleaner)
      pull.rebase = true;

      # Optional but highly recommended: standard shortcuts
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit -m";
      };
    };
  };
}
