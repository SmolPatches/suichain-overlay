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
    overlays = {
      default = final: prev: {
        mkSuiRelease = final.callPackage ./nix/package.nix;
      };
      testnet = final: prev: {
        sui = self.outputs.packages.${final.system};
      };
    };
    # system outputs
    systemOutputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlays.testnet];
      };
    in {
      formatter = pkgs.alejandra;
      packages.sui-bin =
        # default configured test binaries
        pkgs.callPackage ./nix/package.nix {}
        {
          type = "testnet";
          version_number = "1.47.0";
          vhash = "sha256-lG7o6j3nldbdo8Ily4NFp03AyTWEJ6Tsu589ZGKb2AE=";
        };
      packages.default = self.packages.${system}.sui-bin;
    });
  in
    # merge the two into the actual outputs
    {
      overlays = overlays;
      templates.default = {
        path = ./templates/init;
        description = "devshell for sui testnet";
      };
    }
    // systemOutputs;
}
