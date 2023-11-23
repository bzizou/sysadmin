{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [ 
            vim-nix
            vim-addon-nix
            vim-markdown 
            vim-trailing-whitespace
            pathogen 
            editorconfig-vim
            nvim-yarp
            ncm2
            ncm2-ultisnips
            ncm2-bufword
            ncm2-path
            ncm2-tmux
            nvim-cm-racer
            rust-vim ]; 
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
          autocmd BufEnter * call ncm2#enable_for_buffer()
          set completeopt=noinsert,menuone,noselect
        '';
      };
    }
  )];
}
