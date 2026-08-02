{ src, pkgs, ... }:

{
  atrium = pkgs.stdenv.mkDerivation {
    pname = "atrium";
    version = "0.4.0";
    inherit src;

    nativeBuildInputs = with pkgs; [
      meson
      ninja
      pkg-config
      glib
    ];
    buildInputs = with pkgs; [
      systemd
      pam
      gtk4
    ];

    mesonFlags = [ "-Ddist=nixos" "-Ddebug_logging=true" ];

    meta = with pkgs.lib; {
      description = "Wayland multiseat display manager";
      homepage = "https://github.com/kavau/atrium";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      mainProgram = "atrium";
    };
  };
}
