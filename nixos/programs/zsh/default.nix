{ pkgs, config, lib, ... }: {
  programs.starship = import ./starship.nix { inherit lib; };
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
    ];
    zplug = {
      enable = true;
      plugins = [
        {
          name = "plugins/common-aliases";
          tags =
            [ "from:oh-my-zsh" "at:904f8685f75ff5dd3f544f8c6f2cabb8e5952e9a" ];
        }
        {
          name = "plugins/git";
          tags =
            [ "from:oh-my-zsh" "at:904f8685f75ff5dd3f544f8c6f2cabb8e5952e9a" ];
        }
        {
          name = "plugins/extract";
          tags =
            [ "from:oh-my-zsh" "at:904f8685f75ff5dd3f544f8c6f2cabb8e5952e9a" ];
        }
        {
          name = "rupa/z";
          tags = [ "use:z.sh" "at:v1.11" ];
        }
        {
          name = "changyuheng/fz";
          tags = [ "defer:1" "at:2a4c1bc73664bb938bfcc7c99f473d0065f9dbfd" ];
        }
        {
          name = "hlissner/zsh-autopair";
          tags = [ "at:9d003fc02dbaa6db06e6b12e8c271398478e0b5d" "defer:2" ];
        }
        {
          name = "wfxr/forgit";
          tags = [ "at:7b26cd46ac768af51b8dd4b84b6567c4e1c19642" "defer:1" ];
        }
      ];
    };
    initExtraBeforeCompInit = ''
      # fix delete key
      bindkey "^[[3~" delete-char

      # turn off beeping
      unsetopt BEEP

      # ctrl-d drop stash entry
      FORGIT_STASH_FZF_OPTS='--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"'
      setopt HIST_IGNORE_ALL_DUPS
      autoload -U edit-command-line

      # Emacs style
      zle -N edit-command-line
      bindkey '^xe' edit-command-line
      bindkey '^x^e' edit-command-line

      autoload -U select-word-style
      select-word-style bash
    '';

    localVariables = {
      FZF_DEFAULT_COMMAND = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git --exclude node_modules --exclude '*.class'";
      FZF_CTRL_T_OPTS = "--ansi --preview '${pkgs.bat}/bin/bat --style=numbers --color=always --line-range :500 {}'";
      FZF_CTRL_T_COMMAND = "${pkgs.fd}/bin/fd -I --type file";
    };
    history = { extended = true; };
    shellAliases = {
      lsd = "${pkgs.exa}/bin/exa --long --header --git --all";
    };
  };
}
