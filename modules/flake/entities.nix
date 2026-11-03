{
  den.hosts.x86_64-linux = {
    # sshKey: aneesh's key there; logs in to the other host and signs commits
    pc = {
      users.aneesh = {};
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwVvRZ6cNb1mSXehYaqGtX5EkdSb9IqKzdsXPepddhY ab@nouritsu.com";
    };
    laptop = {
      users.aneesh = {};
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaijmb2WJa4WkQNoKz05gibSe/4rIohMVJtY3KSM0va ab@nouritsu.com";
    };
  };
}
