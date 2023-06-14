{ lib, ... }: {
  enable = true;
  settings = {
    add_newline = true;
    git_status = {
      format = ''([\[$conflicted$deleted$renamed$modified$staged$untracked$ahead_behind\]]($style) )'';
    };
    package.disabled = true;
    directory = {
      truncation_length = 10;
      truncate_to_repo = false;
    };
    time = {
      disabled = false;
      format = "[$time]($style)";
    };
    right_format = lib.concatStrings [ "$time" ];
    java.disabled = true;
    kotlin.disabled = true;
    c.disabled = true;
    cmake.disabled = true;
    rust.disabled = true;
    python.disabled = true;
    scala.disabled = true;
    nodejs.disabled = true;
    docker_context.disabled = true;
    vlang.disabled = true;
    vagrant.disabled = true;
    nix_shell = {
      format = "[$symbol$state]($style) ";
      symbol = " ";
      pure_msg = "λ";
      impure_msg = "⎔";
    };
  };
}
