{
  # names are the resident ssh keys' application, ssh:<name>
  den.lib.securityKeys = {
    yubikey-a = {
      ssh = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMnLxjqSr4eW8FTR8/VqPheLwem+4Tyk/xvg7k/YwYxIAAAADXNzaDp5dWJpa2V5LWE= ab@nouritsu.com";
      # age-plugin-fido2-hmac
      age = "age1fido2-hmac1qqpfgqld8xf43lp75pk3s2u78qfrfchxjwlykseega78248e2naczwqqz0m6um5358kz7xc2skmv3u0pzxsdeq2as9sd3zu5nlhhahu9gknfzd2wvv960u0mu6y2mcplh2n32zm5l32azg5xkwr36th0ym2szqgw7750y7q6l4pkpzagk3czksepcpxnv87jrak4rnrm6hw6qqqqwyul7n02";
    };
    yubikey-b = {
      ssh = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILNf7NQHTL6oXtT5EfLaYSzUmr5ibxQnafPM4tKYxq/CAAAADXNzaDp5dWJpa2V5LWI= ab@nouritsu.com";
      age = "age1fido2-hmac1qqpp3q9hkpa4p5l2rd0mpatvuaj609cxhmkkwhk83r7np9u7lln7jcqq28h4m0s0jxklw0yuj6d9kk9yyqyyh73zlr4gnznp6uskfdr3m5r7nv0krv8zgxzqlc0hqpl3fxthl05e62c5anrhtkccp2ew78ng20sx7pnucljwazxk8dg523s22n3qcr7x6kkwntw20vutrl034vpkxyt6lmtk";
    };
  };
}
