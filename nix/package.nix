# export a function that can build varios Linux Sui Versions
{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gccForLibs,
}: let
  mk_release = {
    type ? "testnet",
    version_number,
    arch ? "x86_64",
    vhash,
  }:
    stdenv.mkDerivation rec {
      pname = "sui-binaries";
      version = "${type}-v${version_number}";
      src = fetchurl {
        url = "https://github.com/MystenLabs/sui/releases/download/${version}/sui-${version}-ubuntu-${arch}.tgz";
        hash = vhash;
      };
      sourceRoot = ".";
      nativeBuildInputs = [autoPatchelfHook];
      buildInputs = [gccForLibs.lib];
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp sui* move-analyzer $out/bin
        runHook postInstall
      '';
    };
in
  mk_release
