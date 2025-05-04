{
  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/f9f91492042402e41a4894d0e356da6c0b62c52";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = with pkgs; mkShell {
          buildInputs = [
            ruby_3_4
            rubyPackages_3_4.ruby-lsp
            libyaml
            watchman
            act
            just
          ];
          shellHook = ''
          export BUNDLE_PATH="$PWD/.bundle"
        '';
        };
      }
    );
}
