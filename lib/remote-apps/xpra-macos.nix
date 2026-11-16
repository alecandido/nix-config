{
  fetchurl,
  lib,
  makeWrapper,
  stdenvNoCC,
  undmg,
}:
stdenvNoCC.mkDerivation {
  pname = "xpra-macos";
  version = "6.5.3";

  src = fetchurl {
    url = "https://xpra.org/dists/MacOS/arm64/Xpra-arm64-6.5.3-r0.dmg";
    hash = "sha256-scdnOdy2mkan7CXQIhBfS0PqnHs+KqUgcrRKlUFBfYQ=";
  };

  nativeBuildInputs = [undmg makeWrapper];
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications" "$out/bin"
    cp -R Xpra.app "$out/Applications/"
    makeWrapper "$out/Applications/Xpra.app/Contents/MacOS/Xpra" "$out/bin/xpra"
    runHook postInstall
  '';

  meta = {
    description = "Official Xpra macOS client";
    homepage = "https://xpra.org/";
    license = lib.licenses.gpl2Only;
    platforms = ["aarch64-darwin"];
    mainProgram = "xpra";
  };
}
