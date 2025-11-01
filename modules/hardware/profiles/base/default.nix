{
  config,
  lib,
  ...
}: {
  options.myHardware.profiles.base.enable = lib.mkEnableOption "Base common hardware configuration";

  config = lib.mkIf config.myHardware.profiles.base.enable {
    hardware = {
      enableAllFirmware = true;

      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };

    services = {
      fstrim.enable = true;

      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandlePowerKeyLongPress = "poweroff";
      };
    };

    zramSwap.enable = lib.mkDefault true;
  };
}
