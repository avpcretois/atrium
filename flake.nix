{
  description = "A lightweight Wayland-native multiseat display manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt;
      overlays.default =
        final: prev:
        import ./nix/overlays/default.nix {
          inherit final prev;
          src = self;
        };
      packages.${system}.default =
        (import ./nix/packages/default.nix {
          inherit pkgs;
          src = self;
        }).atrium;
      devShells.${system}.default = import ./nix/devShells/default.nix { inherit pkgs; };
      nixosModules.default =
        { config, lib, pkgs, ... }: import ./nix/nixosModules/default.nix { inherit config lib pkgs; };
    };
}
