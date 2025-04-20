{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gccForLibs,
}:
stdenv.mkDerivation rec {
  pname = "sui-binaries";
  version = "testnet-v1.47.0";
  src = fetchurl {
    url = "https://github.com/MystenLabs/sui/releases/download/${version}/sui-${version}-ubuntu-x86_64.tgz";
    hash = "sha256-lG7o6j3nldbdo8Ily4NFp03AyTWEJ6Tsu589ZGKb2AE=";
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
}
