# darwin.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    alacritty
    vim
  ];

  # User that receives user-scoped nix-darwin defaults and services.
  system.primaryUser = "roshanhegde";

  networking = {
    computerName = "melchior";
    hostName = "melchior";
    localHostName = "melchior";
  };

  system.activationScripts.pinHostname.text = ''
    echo "pinning hostname to melchior..." >&2
    /usr/sbin/scutil --set ComputerName melchior
    /usr/sbin/scutil --set LocalHostName melchior
    /usr/sbin/scutil --set HostName melchior
    /bin/hostname melchior
  '';

  services.karabiner-elements.enable = true;

  # Use upstream nix on macOS and keep daemon/nix.conf owned by nix-darwin.
  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      allowed-users = [ "root" "roshanhegde" ];
      trusted-users = [ "root" "roshanhegde" ];
      experimental-features = [ "nix-command" "flakes" ];
      # Keep performance sane for local builds. Tune as needed.
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "symbola" ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.roshanhegde = {
    name = "roshanhegde";
    home = "/Users/roshanhegde";
  };

  system.defaults = {
    spaces = {
      spans-displays = false;
    };

    # Keyboard settings strictly tailored for Vim/Emacs users
    NSGlobalDomain = {
      KeyRepeat = 2; # Fastest key repeat rate (macOS default is much slower)
      InitialKeyRepeat = 15; # Shortest delay before key repeat begins

      # Disable macOS automatic text manipulations that interfere with coding
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    # Dock and Finder settings
    dock = {
      autohide = true;
      mru-spaces = true;
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv"; # Default to column view
      _FXShowPosixPathInTitle = true; # Show full file path in Finder title
    };

    # Trackpad
    trackpad = {
      Clicking = true; # Enable tap-to-click
      TrackpadThreeFingerDrag = true;
    };
  };

  # Rosetta Linux builder
  nix-rosetta-builder = {
    enable = true;
    onDemand = true; # Optional: start on demand to save battery
    cores = 6;
    memory = "8GiB";
    diskSize = "20GiB";
  };

  ids.gids.nixbld = 350;


}
