{
  description = "Sui Overlay";

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
    # overlays for sui
    overlays.default = final: prev: {
        # latest testnet
        sui = self.outputs.packages.${final.system}.sui-tnet;
        sui-stable = self.outputs.packages.${final.system}.sui-stable;
    };
    # system outputs
    systemOutputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlays.default ];
      };
    in {
      formatter = pkgs.alejandra;
      packages.sui-tnet =
        # default configured test binaries
        # just build the latest test net and export it
        pkgs.callPackage ./nix/package.nix {}
        {
          type = "testnet";
          version_number = "1.47.0";
          vhash = "sha256-lG7o6j3nldbdo8Ily4NFp03AyTWEJ6Tsu589ZGKb2AE=";
        };
      packages.sui-stable =
        # mainnet export
        pkgs.callPackage ./nix/package.nix {}
        {
          type = "mainnet";
          version_number = "1.46.3";
          vhash = "sha256-HbpyaRkjTReiMV1sNxj4rUhVAAOlx8aB3bbgYOj82z8=";
        };
      packages.default = self.packages.${system}.sui-tnet;
    });
  in
    # merge the two into the actual outputs
    {
      overlays = overlays;
      templates = {
        default = {
          path = ./templates/init;
          description = "devshell for sui testnet";
        };
        custom-sui = {
          path = ./templates/custom-sui;
          description = "build a devshell for a specific release";
        };
      };
      # export function to allow custom versions to be built
      lib.mkSuiRelease = pkgs: pkgs.callPackage ./nix/package.nix {};
    }
    // systemOutputs;
}
