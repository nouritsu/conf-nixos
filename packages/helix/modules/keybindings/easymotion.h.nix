{
  flake.nixosModules.whelix-keybinds-easymotion = {...}: {
    settings = {
      editor = {
        jump-label-alphabet = "asdqwezxcrfvtgbyhnujmikolp"; # prefer keys under left hand
      };

      keys.normal.ret = "goto_word";
      keys.select.ret = "extend_to_word";
    };
  };
}
