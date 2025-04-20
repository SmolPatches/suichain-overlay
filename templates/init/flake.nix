{
  description = "sui devshell using overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sui-overlay.url = "github:SmolPatches/suichain-overlay"; # Update this to your overlay flake path
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    sui-overlay,
    flake-utils,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    systemOutputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [sui-overlay.overlays.testnet];
      };
    in {
      devShells.default = pkgs.mkShell {
        name = "sui-dev-shell";
        packages = [sui-overlay.outputs.packages.${system}.default];
      };
      formatter = pkgs.alejandra;
    });
  in
    systemOutputs;
}
