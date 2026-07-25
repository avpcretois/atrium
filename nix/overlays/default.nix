{
  prev,
  final,
  src,
}:
import ../packages/default.nix {
  inherit src;
  pkgs = final;
}
