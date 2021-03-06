{
  description = "C++ parser generator for dissecting protocols & files.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/7ff5e241a2b96fff7912b7d793a06b4374bd846c";
  };
  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = final: prev: {
        spicy = prev.callPackage ./spicy { stdenv = prev.llvmPackages_9.stdenv; };
      };
    }
    //
    (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlay
            ];
          };
        in
        rec {
          packages = flake-utils.lib.flattenTree rec {
            spicy = pkgs.spicy;
          };

          hydraJobs = {
            inherit packages;
          };

          devShell = with pkgs; mkShell {
            buildInputs = [ pkgs.spicy ];
          };
          #
          apps = {
            spicy = flake-utils.lib.mkApp { drv = packages.spicy; exePath = "/bin/spicyc"; };
          };

          defaultPackage = packages.spicy;
          defaultApp = apps.spicy;
        }
      )
    );
}
