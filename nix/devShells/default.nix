{ pkgs, ... }:

with pkgs;
mkShell {
  packages = [
    meson
    ninja
    pkg-config
    gdb
    glibc
    clang-tools
    man-db
    man-pages
    man-pages-posix
  ];
  buildInputs = [
    systemd
    pam
    gtk4
  ];
  shellHook = ''
    export MANPATH="${pkgs.man-pages}/share/man:${pkgs.man-pages-posix}/share/man:$MANPATH"
    echo "Atrium development environment ready"
  '';
}
