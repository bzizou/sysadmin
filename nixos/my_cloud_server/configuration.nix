# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nextcloud.nix
      ./samba.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

#  boot.kernelPackages = pkgs.linuxPackages_5_15;
#  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  networking.hostId = "42c134a0";
  networking.hostName = "albator"; # Define your hostname.
  networking.domain = "bzizou.net";
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.wireless.interfaces = ["wlp1s0"];
  networking.networkmanager.unmanaged = ["w1p1s0"]; # disable wifi interface into networkmanager as it is managed by wpa_supplicant
  networking.wireless.networks.Bbox-37BFA846.pskRaw="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #font = "Lat2-Terminus32";
    keyMap = "fr";
  };

  # Cron 
  services.cron.enable = true;

  # Xwindow system
  services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "modesetting" ];
      displayManager = {
          gdm.enable = true;
          defaultSession = "gnome";
          autoLogin = {
              enable = true;
              user = "mame";
          };
      };
  };

  # For Intel UHD 610 Video driver
  #######################################
  #nixpkgs.config.packageOverrides = pkgs: {
  #  vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #};
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      #intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      #vaapiVdpau
      #libvdpau-va-gl
    ];
  };
  ######################################
 
  # Configure keymap in X11
  services.xserver.layout = "fr";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bzizou = {
     isNormalUser = true;
     extraGroups = [ "wheel" "video" ];
  };
  users.users.mame = {
     isNormalUser = true;
     extraGroups = [ "video" ];
  };
  users.users.gdm = {
     extraGroups = [ "video" ];
  };

  # Extra options
  nix.extraOptions = ''
    trusted-users = root bzizou
    experimental-features = nix-command flakes
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     glxinfo
     dmidecode
     superTuxKart
     p7zip
     chrome-gnome-shell
     gnome.gnome-tweaks
     chromium
     mame
     mailutils
     pciutils
     inetutils
     vim
     wget
     firefox
     zfs
     pmutils
     acpid
     parted
     tmux
     thinkfan
     lm_sensors
     iotop
     dstat
     htop
     git
     tcpdump
     fail2ban
     goaccess
  ];

  services.minidlna = {
    enable = true;
    settings.media_dir =
    [
      "P,/arcadia/Multimedia/Images"
      "V,/arcadia/Multimedia/Images"
      "A,/arcadia/Multimedia/AUDIO"
      "V,/arcadia/Multimedia/VIDEOS"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.squid.enable = true;
  services.squid.extraConfig =
    "url_rewrite_program /nix/store/vlyrb66bz612pswrb96g5zzazag75gh7-squidguard-1.6.0/bin/squidGuard -c /home/squidguard/squidguard.conf";

  #nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Fail2ban
  services.fail2ban.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2869 8200 80 443 139 445 3128 ];
  networking.firewall.allowedUDPPorts = [ 5001 1900 137 138 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Letsencrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "bruno@bzizou.net";
  };

  # Mail config
  services.postfix = {
    enable = true;
    relayHost = "smtp.bbox.fr";
    domain = "bzizou.net";
    hostname = "albator.bzizou.net";
    destination = [ "localhost" "albator" "albator.bzizou.net" ];
    rootAlias = "Bruno@bzizou.net";
    origin = "albator.bzizou.net";
  };

  # Zfs monitoring and mail sending
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${ pkgs.mailutils }/bin/mail";
    ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

