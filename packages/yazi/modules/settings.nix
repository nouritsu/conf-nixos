{
  flake.nixosModules.wyazi-settings = {...}: {
    settings.yazi = {
      mgr = {
        ratio = [1 2 5];
        show_hidden = true;
        linemode = "none";
      };

      plugin = {
        prepend_previewers = [
          {
            url = "*.csv";
            run = "duckdb";
          }
          {
            url = "*.tsv";
            run = "duckdb";
          }
          {
            url = "*.json";
            run = "duckdb";
          }
          {
            url = "*.parquet";
            run = "duckdb";
          }
          {
            url = "*.txt";
            run = "duckdb";
          }
          {
            url = "*.xlsx";
            run = "duckdb";
          }
          {
            url = "*.db";
            run = "duckdb";
          }
          {
            url = "*.duckdb";
            run = "duckdb";
          }
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch";
          }
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
          {
            mime = "application/postscript";
            run = "mediainfo";
          }
          {
            url = "*.md";
            run = ''piper -- glow -w=$w "$1"'';
          }
        ];

        append_previewers = [
          {
            url = "*";
            run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
          }
        ];

        prepend_preloaders = [
          {
            url = "*.csv";
            run = "duckdb";
            multi = false;
          }
          {
            url = "*.tsv";
            run = "duckdb";
            multi = false;
          }
          {
            url = "*.json";
            run = "duckdb";
            multi = false;
          }
          {
            url = "*.parquet";
            run = "duckdb";
            multi = false;
          }
          {
            url = "*.txt";
            run = "duckdb";
            multi = false;
          }
          {
            url = "*.xlsx";
            run = "duckdb";
            multi = false;
          }
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
          {
            mime = "application/postscript";
            run = "mediainfo";
          }
        ];

        prepend_fetchers = [
          {
            group = "git";
            url = "*";
            run = "git";
          }
          {
            group = "git";
            url = "*/";
            run = "git";
          }
        ];
      };
    };
  };
}
