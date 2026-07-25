{ pkgs, ... }:

with pkgs;
mkShell {
  packages = [
    meson
    ninja
    pkg-config
    glib
  ];
  buildInputs = [
    systemd
    pam
    gtk4
  ];
  shellHook = ''
    echo "Atrium development environment ready"
  '';
}
