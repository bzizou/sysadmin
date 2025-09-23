# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-6d87cb82-a47a-49aa-b7d1-xxxxxxxxxxx".device = "/dev/disk/by-uuid/6d87cb82-a47a-49aa-b7d1-xxxxxxxxxx";

  # Kernel version
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "bart"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.extraHosts =
    ''
      176.168.121.32 maison home
    '';

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "-L" # print build logs
    ];
    dates = "12:00";
    randomizedDelaySec = "45min";
  };

  # Enable ntfs
  boot.supportedFilesystems = [ "ntfs" ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  fonts.packages = with pkgs; [
   noto-fonts
   noto-fonts-cjk-sans
   noto-fonts-emoji
   liberation_ttf
   fira-code
   fira-code-symbols
   mplus-outline-fonts.githubRelease
   dina-font
   proggyfonts
   dancing-script
  ];


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  services.thermald.enable = true;

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.printing.browsing = true;
  services.printing.drivers = [ pkgs.hplip ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bzizou = {
    isNormalUser = true;
    description = "Bruno Bzeznik";
    extraGroups = [ "networkmanager" "dialout" "wheel" "audio" "docker" "libvirtd" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

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

  # Build options
  nix.settings.max-jobs = 2;
  nix.settings.cores = 4;
  nix.settings.sandbox = true;
  nix.settings = {
     trusted-substituters = [ "http://nix-binary-cache.u-ga.fr/nix.cache" "http://ciment-grid.univ-grenoble-alpes.fr/nix.cache" "https://cache.nixos.org/" "https://gricad.cachix.org" ];
     require-sigs = false;
     tarball-ttl = 0;
     substituters = [ "http://nix-binary-cache.u-ga.fr/nix.cache" "https://cache.nixos.org" "https://cache.nixos.org/"  "https://gricad.cachix.org" ];
  };

  # Extra options
  nix.extraOptions = ''
    trusted-users = root xxxxxxx
    experimental-features = nix-command flakes
  '';

  # Virtualbox
  virtualisation.virtualbox.host.enable = false;

  # Docker
  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ xxx xxx ];
  networking.firewall.allowedUDPPorts = [ xxx xxx ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # NFS client
  services.rpcbind.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };
 
  # Fingerprint reader
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-broadcom;

  # Firwmares
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
 
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     gh
     cadaver
     keepassxc
     ganttproject-bin
     jq
     hello
     remmina
     python3
     ccid
     hw-probe
     lshw
     usbutils
     just
     virt-manager
     guestfs-tools
     reveal-md
     kstars
     indi-full
     ffmpeg
     zoom-us
     esptool
     arduino
     mkspiffs-presets.arduino-esp32
     arduino-mk
     hardinfo2
     keepass
     handlr
     slack
     xorg.libxcb
     libGL
     appimage-run
     #cura
     blender
     hugo
     p7zip
     mame
     nextcloud-client
     siril
     s-tui
     kdePackages.kdenlive
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
     gnome-tweaks
     htop
     #adobeReader
     bfg-repo-cleaner
     #firefox
     xsel
     ecryptfs
     keyutils
     v4l-utils
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
     xournalpp
     cheese
     at
     hplip
     openconnect
     networkmanager-openconnect
     parted
     mesa
     pavucontrol
     ofono-phonesim
     glib-networking
     #nur.repos.shamilton.vokoscreen-ng
     obs-studio
     black
     telegram-desktop
     audio-recorder
  ];

  # Unsecure packages
  #nixpkgs.config.permittedInsecurePackages = [
  #  "xxxxxxxxxxx"
  #  "xxxxxxxxxxxx"
  #     ];

  # Environment variables
  environment.variables.EDITOR = "vim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
