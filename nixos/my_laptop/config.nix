# /root/.nixpkgs/config.nix

## To have a system wide up-to-date browser and plugins:
# nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# nix-env -i unstable.chromium

{
  allowUnfree = true;
  chromium = { 
     enablePepperFlash = true; 
     enablePepperPDF = true;
     jre = true;
  };

}
