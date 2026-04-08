{
  flake.nixosModules.app-scrcpy = {
    pkgs,
    lib,
    ...
  }: let
    # constants
    PHONE_MODEL = "model:Pixel_9_Pro_XL";

    # pkgs
    notify-send = lib.getExe' pkgs.libnotify "notify-send";

    phone-mirror = pkgs.writers.writeFishBin "" ''
      set ip (adb devices -l | string match "*model:Pixel_9_Pro_XL*" | string match -r '^\S+')

      if test -z "$ip"
          notify-send -u critical "ADB Error" "Pixel 9 Pro XL not found in device list."
          exit 1
      end

      set notif_id (notify-send -p "ADB" "Connecting to Pixel 9 Pro XL ($ip)...")
      set connect_output (timeout 5s adb connect $ip)

      if not string match -q "*connected*" $connect_output
          notify-send -r $notif_id -u critical "ADB Error" "Connection failed: $connect_output"
      end
    '';
  in {
  };
}
