# flake.nix

{
  description = "Cross-platform Home Manager and nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
    nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      nix-rosetta-builder,
      ...
    }:
    let
      username = "roshanhegde";
      darwinSystem = "aarch64-darwin";
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      systems = [ darwinSystem ] ++ linuxSystems;

      nixpkgsConfig = {
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "symbola" ];
      };

      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        };

      homeDirectoryFor =
        system: if nixpkgs.lib.hasSuffix "darwin" system then "/Users/${username}" else "/home/${username}";

      homeModulesFor = system: [
        ./home.nix
        {
          home = {
            inherit username;
            homeDirectory = homeDirectoryFor system;
          };
        }
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            name = "nix-config";
            packages = with pkgs; [
              nixfmt
            ];
          };
        }
      );

      homeConfigurations = builtins.listToAttrs (
        map (system: {
          name = "${username}@${system}";
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor system;
            modules = homeModulesFor system;
          };
        }) systems
      );

      darwinConfigurations.melchior = darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = { inherit inputs; };
        modules = [
          ./darwin.nix
          nix-rosetta-builder.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} =
              { ... }:
              {
                imports = homeModulesFor darwinSystem;
              };
          }
        ];
      };

      nixosModules.home-manager =
        { lib, pkgs, ... }:
        {
          imports = [
            home-manager.nixosModules.home-manager
          ];

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nixpkgs.config = nixpkgsConfig;
          programs.zsh.enable = true;

          users.users.${username} = {
            isNormalUser = lib.mkDefault true;
            home = lib.mkDefault "/home/${username}";
            extraGroups = lib.mkDefault [ "wheel" ];
            shell = lib.mkDefault pkgs.zsh;
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} =
            { pkgs, ... }:
            {
              imports = homeModulesFor pkgs.stdenv.hostPlatform.system;
            };
        };
    };
}
