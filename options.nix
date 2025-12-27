{lib, ...}: let
  supported_graphics = ["nvidia" "intel"];
  supported_system_kinds = ["desktop" "laptop"];

  email_regex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
in {
  options.my = {
    system = lib.mkOption {
      type = lib.types.submodule {
        options = {
          arch = lib.mkOption {
            type = lib.types.str;
            description = "System architecture";
          };

          kind = lib.mkOption {
            type = lib.types.enum supported_system_kinds;
            description = "System kind";
          };

          hostname = lib.mkOption {
            type = lib.types.str;
            description = "Machine hostname";
          };

          graphics = lib.mkOption {
            type = lib.types.enum supported_graphics;
            description = "Graphics driver (null for none)";
          };
        };
      };
      description = "System Details";
    };

    user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "User Full Name";
          };

          email = lib.mkOption {
            type = lib.types.strMatching email_regex;
            description = "User Email";
          };

          alias = lib.mkOption {
            type = lib.types.str;
            description = "User Alias";
          };
        };
      };
      description = "User Details";
    };
  };
}
