# build a sui derivation based on some configurable params
{
  lib,
  platform ? stdenv.hostPlatform,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  gccForLibs,
}:

let
  hash_table = {
    "aarch64-darwin" = "sha256-zmDNCVxkc676CMylYr7MCB17FWl5S2FtDwE0YySEldE=";
    "x86_64-darwin" = "";
    "aarch64-linux" = "";
    "x86_64-linux" = "";
  };
  mk_release =
    # builder function
    {
      type ? "testnet",
      version_number,
      arch ? if lib.strings.hasInfix "x86_64" platform.system then "x86_64" else "aarch64",
      vhash ? hash_table."${platform.system}",
    }:
    let
      triple =
        if platform.isLinux then
          "ubuntu-${arch}"
        else if arch == "aarch64" then
          "macos-arm64"
        else
          "macos-x86_64"; # src tarball triple
    in

    # sui package built from binary
    # source builds blocked on rust / git issues
    # https://github.com/NixOS/nixpkgs/pull/282798
    # https://github.com/NixOS/nixpkgs/issues/303467
    stdenv.mkDerivation (finalAttrs: {
      pname = "sui-mainnet";
      version = version_number;
      src = fetchzip {
        url = "https://github.com/MystenLabs/sui/releases/download/${type}-v${finalAttrs.version}/sui-${type}-v${finalAttrs.version}-${triple}.tgz";
        hash = vhash;
        stripRoot = false;
      };
      nativeBuildInputs = lib.optionals platform.isLinux [
        autoPatchelfHook
      ];
      buildInputs = lib.optionals platform.isLinux [ gccForLibs.lib ];
      installPhase = ''
        runHook preInstall
        install -m 755 -d $out/bin
        install -m 755 sui* move-analyzer $out/bin
        runHook postInstall
      '';
      # check the version for each binary
      installCheckPhase = ''
        runHook preInstallCheck
        for f in $out/bin/*; do
             echo Checking version for $f
             if [[ ! $f =~ "${finalAttrs.version}" ]] then
                  echo FAILED $f: "${finalAttrs.version}"
                  exit 1
              fi
         done
         runHook postInstallCheck
      '';
      doInstallCheck = true;
      meta = {
        longDescription = "Sui, a next-generation smart contract platform with high throughput, low latency, and an asset-oriented programming model powered by the Move programming language";
        description = "patched Sui binaries for nix compat";
        homepage = "https://sui.io/";
        changelog = "https://github.com/MystenLabs/sui/releases/tag/${type}-v${version_number}";
        downloadPage = "https://github.com/MystenLabs/sui";
        license = lib.licenses.asl20;
        platforms = lib.platforms.linux ++ lib.platforms.darwin;
        mainProgram = "sui";
        maintainers = with lib.maintainers; [ smolpatches ];
      };
    });
in
mk_release 
