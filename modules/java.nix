{ pkgs, ... }:

{
    programs.java = {
          enable = true;
              package = pkgs.jdk; # Installs the current OpenJDK LTS release
                };
              }
