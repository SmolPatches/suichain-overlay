# Sui Overlay
An overlay for Sui tools
binaries are patched and not built form source

# Usage
## Local Builds
Build the latest mainnet for sui for local use  
`nix build github.com:suichain-overlay#sui-stable`  
Build the latest testnet for local use  
`nix build github.com:suichain-overlay`  
## Local Dev Shell
Enable a devShell for a specific Sui version  
Template:  
`nix flake init -t github:smolpatches/suichain-overlay#custom-sui`
```nix
{
  description = "sui devshell using overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sui-overlay.url = "github:SmolPatches/suichain-overlay"; 
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
```

Use the the latest testnet  
Template:  
`nix flake init -t github:smolpatches/suichain-overlay`
```nix
{
  description = "sui devshell using overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sui-overlay.url = "github:SmolPatches/suichain-overlay"; 
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
        overlays = [ sui-overlay.overlays.default ]  ;
      };
    in {
      devShells.default = pkgs.mkShell {
        name = "sui-dev-shell";
        packages = [ pkgs.sui ]; # install latest tnet release
        #packages = [ pkgs.sui-stable ]; # install latest main release
      };
      formatter = pkgs.alejandra;
    });
  in
    systemOutputs;
}
```
# TODO
- add support for mac
  - find a way to make remove the need for overlay to supply hash
- add example of using custom release or overlay to in runCommand or a build chain
# References
Nix can be hard, but thanks to my fore fathers I am able to learn and do new things too

## Forefathers

[Zig Overlay](https://github.com/mitchellh/zig-overlay), a digestable start for language overlays  
[Rust Overlay](https://github.com/mitchellh/zig-overlay), a look into more complicated options and modularity  
[Ghostty](https://github.com/ghostty-org/ghostty), lots of crazy nix magic, VMs and general nixonics  
[Nixpkgs ref](https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases), great way to start to understand packaging @ a deeper level  
[Nixos-Wiki:Packaging binaries](https://wiki.nixos.org/wiki/Packaging/Binaries), some intro to patchelf  
