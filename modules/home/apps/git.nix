{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "scott";
        email = "scottc96@proton.me";
      };

      init.defaultBranch = "main";
    };
  };
}
