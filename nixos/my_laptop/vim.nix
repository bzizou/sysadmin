{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [ vim-nix vim-markdown pathogen editorconfig-vim nvim-completion-manager nvim-cm-racer ]; 
          opt = [];
        };
        customRC = ''
          set nocompatible
          set mouse=
          set backspace=indent,eol,start
          set nofoldenable
          let $RUST_SRC_PATH = '${stdenv.mkDerivation {
            inherit (rustc) src;
            inherit (rustc.src) name;
            phases = ["unpackPhase" "installPhase"];
            installPhase = ''cp -r library $out'';
          }}'
        '';
      };
    }
  )];
}
