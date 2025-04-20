{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    formatter."x86_64-linux" = pkgs.alejandra;
    packages.x86_64-linux.sui-binary = pkgs.callPackage ./nix/package.nix {};

    packages.x86_64-linux.default = self.packages.x86_64-linux.sui-binary;
    overlays.default = final: prev: {
      sui = self.outputs.packages.${prev.system};
    };
  };
}
