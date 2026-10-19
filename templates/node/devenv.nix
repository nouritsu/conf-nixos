{
  languages.javascript = {
    enable = true;
    # npm install runs as a task whenever package.json changes
    npm = {
      enable = true;
      install.enable = true;
    };
  };

  languages.typescript.enable = true;

  treefmt.config.programs.prettier.enable = true;

  scripts.dev.exec = ''npm run dev "$@"'';

  enterTest = "npm test";
}
