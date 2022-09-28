# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Thermald necessary to fix Dell Latitude and it's Intel core i7 running at 400Mhz on heavy load
  #services.thermald.enable = true;
  services.throttled.enable = true;

  # Always use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable ntfs
  boot.supportedFilesystems = [ "ntfs" ];

  security.pam.enableEcryptfs = true;

  networking.hostName = "bart"; # Define your hostname.

  networking.extraHosts =
    ''
      176.168.121.32 maison home
      #129.88.1.140 ciment.ujf-grenoble.fr ciment.imag.fr ciment
    '';

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Network manager
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "inreface-name:ve-*" ];
  #networking.networkmanager.dhcp = "dhcpcd";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
     #font = "Lat2-Terminus32";
     font = "Lat2-Terminus16";
     keyMap = "fr";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
 
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Configure keymap in X11
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.printing.browsing = true;
  services.printing.drivers = [ pkgs.hplip ];

  # For browsing
  services.avahi.nssmdns = true;
  services.avahi.domainName = "arcadia";
#  services.avahi.extraServiceFiles = 
#    {
#    smb = ''
#      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
#      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
#      <service-group>
#        <name replace-wildcards="yes">%h</name>
#        <service>
#          <type>_smb._tcp</type>
#          <port>445</port>
#        </service>
#      </service-group>
#    '';
#    };
  services.samba.enable = true;
  services.samba.enableNmbd = true;
  
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  users.extraUsers.bzizou = {
    extraGroups = [ "audio" "docker" "wheel" ];
    isNormalUser = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     s-tui
     kdenlive
     irssi
     texmaker
     texlive.combined.scheme-full
     nixpkgs-review
     nixpkgs-fmt
     stellarium
     hwinfo
     read-edid
     samba
     cifs-utils
     xorg.xhost
     gnumake
     wol
     signal-desktop
     gnome.gnome-tweaks
     htop
     #adobeReader
     bfg-repo-cleaner
     firefox
     xsel
     ecryptfs
     ecryptfs-helper
     keyutils
     v4l_utils
     uvcdynctrl
     guvcview
     qemu_kvm
     nfs-utils
     rpcbind
     vimPlugins.pathogen 
     vimPlugins.vim-markdown
     vimPlugins.editorconfig-vim
     ethtool
     nmap
     tcpdump
     nox
     pciutils
     terminator
     tmux
     powertop
     openssh
     dmidecode
     chromium
     google-chrome
     thunderbird
     firefox
     #networkmanagerapplet
     bluez-tools
     bluez
     xorg.xbacklight
     ethtool
     gnupg
     psmisc
     docker
     ksuperkey
     which
     avahi
     acpitool
     libsForQt5.phonon
     gitAndTools.gitFull
     wget
     evince
     libreoffice-fresh
     mplayer
     binutils
     cpufrequtils
     pidgin
     geeqie
     dia
     xfce.xfwm4
     inetutils
     gimp-with-plugins
     hunspellDicts.fr-any
     #tightvnc
     turbovnc
     inkscape
     unzip
     subversion
     unrar
     vlc
     #kde5.kdenlive
     bc
     glxinfo
     imagemagick
     unetbootin
     unrar
     xournal
     gnome3.cheese
     at
     hplip
     openconnect
     networkmanager-openconnect
     parted
     mesa.drivers
     mesa
     pavucontrol
     ofono-phonesim
     glib-networking
     vim
    # (
    #   (vim_configurable.override { python = python3; }).customize{
    #     name = "vi";
    #     vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
    #       start = [ vim-nix vim-markdown pathogen editorconfig-vim ];
    #       opt = [];
    #     };
    #     vimrcConfig.customRC = ''
    #      syntax enable
    #       set mouse=
    #       set ttymouse=
    #       set backspace=indent,eol,start
    #     '';
    #   }
    # )

    #nur.repos.shamilton.vokoscreen-ng
    obs-studio
  ];

  # Unsecure packages
  nixpkgs.config.permittedInsecurePackages = [
         "adobe-reader-9.5.5-1"
       ];


  # Environment variables
  environment.variables.EDITOR = "vi";

  # nixpkgs config
  nixpkgs.config = {
    allowUnfree = true;
 
    # NUR
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # NFS client
  services.rpcbind.enable = true;

  # DNS forwarder
  #services.bind.enable = true;

  # Build options
  nix.maxJobs = 8;
  nix.useSandbox = true;
  nix.settings = {
     trusted-substituters = [ "http://nix-binary-cache.u-ga.fr/nix.cache" "http://ciment-grid.univ-grenoble-alpes.fr/nix.cache" "https://cache.nixos.org/" "https://gricad.cachix.org" ];
     require-sigs = false;
     tarball-ttl = 0;
     substituters = [ "http://nix-binary-cache.u-ga.fr/nix.cache" "https://cache.nixos.org" "https://cache.nixos.org/"  "https://gricad.cachix.org" ];
  };

  # Extra options
  nix.extraOptions = ''
    trusted-users = root bzizou
    experimental-features = nix-command flakes
  ''; 

  # Virtualbox
  virtualisation.virtualbox.host.enable = false;
  
  # Docker
  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

