My configs and tools, managed using nix and home manager

## Layout

```text
.
|-- flake.nix
|-- flake.lock
|-- darwin.nix
|-- home.nix
`-- modules/
    |-- alacritty-settings.nix
    |-- cli.nix
    |-- emacs.nix
    |-- git.nix
    |-- java.nix
    |-- tmux.nix
    `-- vim.nix
```

## Apply

On macOS:

```sh
darwin-rebuild switch --flake ~/.config/nix#melchior
```

Standalone Home Manager on Linux:

```sh
home-manager switch --flake ~/.config/nix#roshanhegde@x86_64-linux
```

Standalone Home Manager on Apple Silicon macOS:

```sh
home-manager switch --flake ~/.config/nix#roshanhegde@aarch64-darwin
```

In a NixOS flake, wire this repo as an input:

```nix
{
  inputs.nix-config.url = "path:/home/roshanhegde/.config/nix";
}
```

Then add the module to the host:

```nix
{
  imports = [
    inputs.nix-config.nixosModules.home-manager
  ];
}
```

## Maintenance

Check evaluation:

```sh
nix flake check --no-build
nix eval '.#homeConfigurations."roshanhegde@x86_64-linux".activationPackage.drvPath'
nix eval '.#homeConfigurations."roshanhegde@aarch64-linux".activationPackage.drvPath'
nix eval '.#homeConfigurations."roshanhegde@aarch64-darwin".activationPackage.drvPath'
```

Format Nix files:

```sh
nixfmt flake.nix home.nix darwin.nix modules/*.nix
```
