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
      pkgs = nixpkgs.legacyPackages.${system};
      devnet = sui-overlay.lib.mkSuiRelease pkgs {
        # new package for sui 1.46.0
        type = "devnet"; # testnet devnet mainnet
        version_number = "1.46.0";
        vhash = "sha256-4rINWAScAdpNsj3RL6Dw128Mm44SV5ueKqMgfQfVjaA=";
      };
    in {
      devShells.default = pkgs.mkShell {
        name = "sui-dev-shell";
        packages = [
          devnet
        ];
      };
      formatter = pkgs.alejandra;
    });
  in
    systemOutputs;
}
