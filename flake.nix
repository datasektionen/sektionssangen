{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

        buildDeps = with pkgs; [
          gcc
          gnu-cim
        ];
      in
      {
        packages =
          let
            sektionssangen = pkgs.stdenvNoCC.mkDerivation {
              pname = "sektionssangen";
              version = "1.0.0";

              src = builtins.filterSource (
                path: _:
                let
                  # path looks like /nix/store/hash/{filename}
                  filename = builtins.elemAt (lib.splitString "/" path) 4;
                in
                builtins.elem filename [
                  "song.sim"
                ]
              ) ./.;

              nativeBuildInputs = buildDeps;

              buildPhase = ''
                cim -o sektionssangen song.sim
              '';

              installPhase = ''
                mkdir -p $out/bin
                cp sektionssangen $out/bin/
              '';
            };
          in
          {
            inherit sektionssangen;
            default = sektionssangen;
          };

        checks = {
          build-project = self.packages.${system}.sektionssangen;
        };

        devShells.default = pkgs.mkShell {
          packages = buildDeps;
        };
      }
    );
}
