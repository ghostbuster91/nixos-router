{ pkgs, config, ... }:
let
  leaderKey = "\\<Space>";
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      	let mapleader = "${leaderKey}"
    '' +
    "${builtins.readFile ./init.vim}" +
    ''
      lua << EOF
        ${builtins.readFile ./init.lua}
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      rec {
        plugin = kanagawa-nvim;
        config = ''
          packadd! ${plugin.pname}
          colorscheme kanagawa
        '';
      }
      {
        plugin = telescope-nvim;
        config = ''
          "It has to be set in the first plugin's config as plugins get sourced before any other configuration and the leader customization doesn't work otherwise
          let mapleader = "${leaderKey}" 
          nnoremap <Leader>tf <cmd>Telescope find_files<cr>
          nnoremap <Leader>th <cmd>Telescope buffers<cr>
          nnoremap <Leader>gh <cmd>lua require('telescope.builtin').git_commits()<cr>

          lua << EOF
              vim.keymap.set("n", "<leader>hc", function()
                require("telescope.builtin").git_bcommits()
              end, { desc = "Buffer commites"})
              vim.keymap.set("n", "<leader>tg", function()
                require("telescope.builtin").live_grep({ layout_strategy = "vertical" })
              end, { desc = "Live grep"})
          EOF
        '';
      }
      telescope-fzf-native-nvim
      which-key-nvim
      nvim-autopairs
      {
        plugin = vim-sandwich;
        #config = ''
        #  runtime macros/sandwich/keymap/surround.vim
        #'';
      }
      gitsigns-nvim
      plenary-nvim

      # completions
      nvim-cmp
      cmp-buffer
      cmp-path

      (nvim-treesitter.withPlugins (
        # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/development/tools/parsing/tree-sitter/grammars
        plugins:
          with plugins; [
            tree-sitter-lua
            tree-sitter-vim
            tree-sitter-html
            tree-sitter-yaml
            tree-sitter-json
            tree-sitter-markdown
            tree-sitter-comment
            tree-sitter-bash
            tree-sitter-javascript
            tree-sitter-nix
            tree-sitter-typescript
            tree-sitter-c
            tree-sitter-java
            tree-sitter-python
            tree-sitter-go
            tree-sitter-hocon
            tree-sitter-sql
            tree-sitter-graphql
            tree-sitter-dockerfile
            tree-sitter-scheme
            tree-sitter-rust
            tree-sitter-smithy
          ]
      ))
      nvim-treesitter-textobjects

      nvim-web-devicons
      lualine-nvim
      comment-nvim

      nvim-neoclip-lua
      indent-blankline-nvim
      nvim-tree-lua
      telescope-ui-select-nvim
      noice-nvim
      nui-nvim
      neoscroll-nvim
      neogit
      undotree
      vim-repeat # needed for leap
    ];
  };
}
