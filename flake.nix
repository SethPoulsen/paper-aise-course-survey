{
  description = "Student AISE Course Survey Paper";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          lib,
          ...
        }:
        let
          build = with pkgs; [
            texliveFullWithDocs
            graphviz
            python312Packages.pygments
          ];
        in
        {
          apps.default = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "build-pdf" ''
                export PATH=${lib.makeBinPath build}/bin:$PATH
                pdflatex -shell-escape paper-aise-course-survey.tex
                bibtex paper-aise-course-survey
                pdflatex -interaction=nonstopmode -shell-escape paper-aise-course-survey.tex
                pdflatex -interaction=nonstopmode -shell-escape paper-aise-course-survey.tex
              ''
            );
          };

          devShells.default = pkgs.mkShell {
            packages = build ++ [ pkgs.texlab ];
          };
        };
    };
}
