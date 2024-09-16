{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    main-user.enable = lib.mkEnableOption "enable user module";
    main-user.userName = lib.mkOption {
      default = "hannesf";
      description = ''
        username
      '';
    };
  };
  config = lib.mkIf config.main-user.enable {
    users.users.${config.main-user.userName} = {
      isNormalUser = true;
      description = "Hannes Furmans";
      initialPassword = "12345";
      extraGroups = ["networkmanager" "wheel" "docker" "audio" "ipfs" "video"];
    };
  };
}
