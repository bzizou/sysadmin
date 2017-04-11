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

  networking.hostName = "quath-icat"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.interfaces.enp5s0f0.ipAddress = "195.220.82.31";
  networking.interfaces.enp5s0f0.prefixLength= 26;
  networking.defaultGateway = "195.220.82.1";
  networking.nameservers = [ "127.0.0.1" ];
  networking.search = [ "univ-grenoble-alpes.fr" "u-ga.fr" "ujf-grenoble.fr" ];
  networking.proxy.allProxy = "http://www-cache.ujf-grenoble.fr:3128";

  # Name server forwarder
  services.bind.enable = true;
  services.bind.forwarders = [ "152.77.1.22" "152.77.1.22" ];
  services.bind.cacheNetworks = [ "127.0.0.0/24" 
                                  "195.220.81.0/24" 
                                  "152.77.100.0/24" 
                                  "195.220.82.0/24" ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ 53 1247 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     wget
     vim
     iotop
     dstat
     iftop
     git
     dmidecode
     tcpdump
     tmux 
  ];

  # Enable docker virtualization      
  virtualisation.docker.enable = true;

  time.timeZone = "Europe/Paris";

  environment.variables.EDITOR = "vim";

  environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ psql ] ;

  services.ntp.enable = true;
 
  services.ntp.servers = [ "ntp.u-ga.fr" ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  # Enable parallel build
  nix.maxJobs = 16 ;

  # Local hostnames config
  networking.extraHosts = "

195.220.82.10   cypher.ujf-grenoble.fr cypher
10.0.10.2       ipmi-console

195.220.82.31 quath-icat.ujf-grenoble.fr quath-icat

";

}
