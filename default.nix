let
  overlays = [
    (import ./packages-overlay.nix)
  ];

  pkgs = (import <nixpkgs>) { inherit overlays; };
in
pkgs.buildEnv {
  name = "test-spicy";
  paths = with pkgs; [
    spicy
  ];
}
