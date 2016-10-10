# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_4_7;

  networking.hostName = "bart"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
   i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "fr";
     defaultLocale = "en_US.UTF-8";
   };

  # Set your time zone.
    time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     vim 
     ethtool
     nox
     pciutils
     terminator
     tmux
     powertop
     openssh
     dmidecode
     chromium
     thunderbird
     firefox
     #networkmanagerapplet
     bluez-tools
     xorg.xbacklight
     ethtool
     gnupg
     psmisc
     docker
     ksuperkey
     which
     avahi
     acpitool
  ];

  nixpkgs.config = {

    allowUnfree = true;

    firefox = {
     enableGoogleTalkPlugin = true;
     enableAdobeFlash = true;
    };

    chromium = {
     enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
     enablePepperPDF = true;
    };

  };

  virtualisation.docker.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
    services.printing.enable = true;

  # For network printing
    services.avahi.enable = true;
    services.printing.browsing = true;

  # Enable the X11 windowing system.
    services.xserver.enable = true;
    #services.xserver.videoDrivers = [ "modesetting" "intel" ];
    services.xfs.enable = true;
    fonts.enableFontDir = true;
    services.xserver.layout = "fr";
    services.xserver.xkbVariant = "latin9";
    services.xserver.xkbOptions = "eurosign:e";
    services.xserver.synaptics.enable = true;
    services.xserver.synaptics.twoFingerScroll = true;
    services.xserver.exportConfiguration = true;
    services.xserver.displayManager.sessionCommands = ''
      # Start network manager applet
      #${pkgs.networkmanagerapplet}/bin/nm-applet &
      # Make the Meta key act into KDE like into Gnome
      ksuperkey -e "Super_L=Control_L|F10" 
      '';

 

  # Enable the KDE Desktop Environment.
   services.xserver.displayManager.kdm.enable = true;
   services.xserver.desktopManager.kde5.enable = true;
  #  services.xserver.displayManager.gdm.enable = true;
   services.xserver.desktopManager.gnome3.enable = true;

  # Enable network manager
    networking.networkmanager.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

}
