{
  description = "RenderCV development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            uv
            just
            python313
            git
            # CV rendering pipeline (cv/render.sh): docx conversion + PDF checks
            pandoc
            poppler-utils
          ];

          env = {
            # uv's managed Python builds are linked against an FHS loader path
            # and do not run on NixOS; force the nixpkgs interpreter instead.
            UV_PYTHON_DOWNLOADS = "never";
            UV_PYTHON = "${pkgs.python313}/bin/python3";
          };

          shellHook = ''
            # Fallback for manylinux wheels whose extensions expect libstdc++/zlib
            # to be findable without an FHS ld cache.
            export LD_LIBRARY_PATH=${
              pkgs.lib.makeLibraryPath [
                pkgs.stdenv.cc.cc.lib
                pkgs.zlib
              ]
            }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
          '';
        };
      });
    };
}
