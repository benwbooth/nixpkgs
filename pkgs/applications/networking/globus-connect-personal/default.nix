{ lib, stdenv, fetchurl, makeDesktopItem, copyDesktopItems, makeWrapper, tcllib, tk, xorg, fontconfig, gtk2-x11, atk, libGL, zlib }:

stdenv.mkDerivation rec {
  pname = "globus-connect-personal";
  version = "3.2.2";

  src = fetchurl {
    url = "https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz";
    hash = "sha256-F4shENyrQfO1jaZ1+pia/DrTtiW42V7w/JUjoTKV/cI=";
  };

  buildInputs = [
    tk
    tcllib
    xorg.libXft
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "Globus Connect Personal";
      exec = "globusconnectpersonal";
      comment = "Share and transfer files";
      desktopName = "globus-connect-personal";
      genericName = "Share and transfer files";
      #icon = "globusconnectpersonal";
    })
  ];

  installPhase = ''
    runHook preInstall
    install -d "$out/opt/globusconnectpersonal" "$out/bin" "$out/share/pixmaps"
    cp -r ./. "$out/opt/globusconnectpersonal"
    #install -Dm644 images/JX128.png "$out/share/pixmaps/globusconnectpersonal.png"
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/globusconnectpersonal/globusconnectpersonal $out/bin/globusconnectpersonal \
      --chdir $out/opt/globusconnectpersonal \
      --set LD_LIBRARY_PATH ${xorg.libXft}/lib:${fontconfig.lib}/lib:${xorg.libX11}/lib:${xorg.libXScrnSaver}/lib:${gtk2-x11}/lib:${atk}/lib:${libGL}/lib:${xorg.libxcb}/lib:${zlib}/lib
  '';

  meta = with lib; {
    description = "A Java Ldap Browser";
    homepage    = "https://docs.globus.org/how-to/globus-connect-personal-linux/";
    license     = lib.licenses.asl20;
    maintainers = with maintainers; [ benwbooth ];
    platforms   = platforms.linux;
  };
}
