{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [ vim-nix vim-markdown pathogen editorconfig-vim ]; 
          opt = [];
        };
        customRC = ''
          " your custom vimrc
          set nocompatible
          set mouse=
          set backspace=indent,eol,start
          " ...
        '';
      };
    }
  )];
}
