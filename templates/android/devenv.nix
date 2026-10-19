{pkgs, ...}: {
  languages.kotlin.enable = true;

  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk21;
    gradle.enable = true;
  };

  # sdk, platform-tools, build-tools; ANDROID_HOME and local.properties
  android = {
    enable = true;
    platforms.version = ["36"];
    # flip on for an AVD
    emulator.enable = false;
    systemImages.enable = false;
    ndk.enable = false;
  };

  treefmt.config.programs.ktfmt.enable = true;

  scripts.install-debug.exec = "./gradlew installDebug";

  enterTest = "./gradlew test";
}
