{config, pkgs, ...}:
{

  services.samba = {
    enable = true;
    securityType = "user";
    # Create users with "smbpasswd -a yourusername"
    extraConfig = ''
      log level = 3
      workgroup = ARCADIA
      server string = albator
      netbios name = albator
      security = user 
      #use sendfile = yes
      min protocol = NT1
      hosts allow = 192.168.1.0/24  localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      homes = {
        browseable = "no";
        "read only" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "valid users" = "%S";
        comment = "Home Directories";
      };
      multimedia = {
        browseable = "yes";
        "read only" = "yes";
        "public" = "yes";
        comment = "Multimedia directory";
        path = "/arcadia/Multimedia";
      };
    };
  
  };
}
