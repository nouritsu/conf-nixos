{
  # devenv up runs these; add the app as processes.<name>
  services.postgres = {
    enable = true;
    initialDatabases = [{name = "app";}];
  };

  services.redis.enable = true;

  scripts.db.exec = ''psql "''${1:-app}"'';

  # devenv test starts the services first
  enterTest = ''
    timeout 30 sh -c 'until pg_isready -q -d app; do sleep 1; done'
  '';
}
