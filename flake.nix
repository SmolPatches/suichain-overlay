{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    systems = with flake-utils.lib.system; [x86_64-linux aarch64-linux]; # binary platforms for sui
  in
    flake-utils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;
      packages.sui-binary = pkgs.callPackage ./nix/package.nix {};
      packages.default = self.packages.${system}.sui-binary;
      overlays.default = final: prev: {
        sui = self.outputs.packages.${prev.system};
      };
    });
}
