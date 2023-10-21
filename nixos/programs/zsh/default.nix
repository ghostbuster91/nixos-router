{ pkgs, config, lib, ... }:
let
  omz = pkgs.fetchFromGitHub
    {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "68f3ebb4de11aa2013ccc5252d4415840e0d7342";
      hash = "sha256-5QsedauFgdhRDY6P2eMewGSLPWSaed2xZEcvTRYSrTs=";
    };
in
{
  programs.starship = import ./starship.nix {
    inherit lib;
  };
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    enableVteIntegration = true;
    defaultKeymap = "emacs";
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
      {
        name = "omz-ssh-agent";
        src = omz;
        file = "plugins/ssh-agent/ssh-agent.plugin.zsh";
      }
      {
        name = "omz-common-aliases";
        src = omz;
        file = "plugins/common-aliases/common-aliases.plugin.zsh";
      }
      {
        name = "omz-git";
        src = omz;
        file = "plugins/git/git.plugin.zsh";
      }
      {
        name = "omz-extract";
        src = omz;
        file = "plugins/extract/extract.plugin.zsh";
      }
      {
        name = "zsh-forgit";
        src = pkgs.zsh-forgit;
        file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
      }
    ];
    initExtraBeforeCompInit = ''
      # fix delete key
      bindkey "^[[3~" delete-char

      # turn off beeping
      unsetopt BEEP

      # ctrl-d drop stash entry
      setopt HIST_IGNORE_ALL_DUPS
      autoload -U edit-command-line

      # Emacs style
      zle -N edit-command-line
      bindkey '^xe' edit-command-line
      bindkey '^x^e' edit-command-line

      autoload -U select-word-style
      select-word-style bash
    '';

    initExtraFirst = ''
      export FORGIT_STASH_FZF_OPTS="--bind='ctrl-d:reload(${pkgs.git}/bin/git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && ${pkgs.git}/bin/git stash list)'"
      export FZF_CTRL_T_COMMAND="${pkgs.fd}/bin/fd -I --type file"
      export FZF_CTRL_T_OPTS="--ansi --preview '${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'"
      export FZF_DEFAULT_COMMAND="${pkgs.fd}/bin/fd --type f --hidden --exclude .git --exclude node_modules --exclude '*.class'";
    '';
    history = { extended = true; };
    shellAliases = {
      lsd = "${pkgs.eza}/bin/exa --long --header --git --all";
    };
  };
}
