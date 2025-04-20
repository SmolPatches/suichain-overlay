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
    overlays = {
      testnet = final: prev: {
        sui = self.outputs.packages.${final.system};
      };
    };
  in
    {
      overlays = overlays;
    }
    // flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlays.testnet];
      };
    in {
      formatter = pkgs.alejandra;
      packages.sui-binary = pkgs.callPackage ./nix/package.nix {};
      packages.default = self.packages.${system}.sui-binary;
    });
}
