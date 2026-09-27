{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    delta = lib.getExe self'.packages.delta;

    # Carried over from home-manager's gh module, which wrote it into the
    # config this replaces. gh's git_protocol is https, so without it every
    # push to GitHub asks for credentials. The empty entry clears any helper
    # inherited from a lower scope.
    gh = ["" "${lib.getExe pkgs.gh} auth git-credential"];
  in {
    packages.git = wrappers.wrappers.git.wrap [
      {
        inherit pkgs;
        package = pkgs.git;
      }

      self.nixosModules.wgit-identity

      {
        settings = {
          credential."https://github.com".helper = gh;
          credential."https://gist.github.com".helper = gh;

          pager = {
            diff = delta;
            log = delta;
            show = delta;
            blame = delta;
          };
          interactive.diffFilter = "${delta} --color-only";
        };
      }
    ];
  };
}
