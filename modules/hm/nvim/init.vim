set mouse=a
      	
syntax on

set relativenumber
set number
set wildcharm=<C-Z>

set termguicolors

"This unsets the "last search pattern" register by hitting return
nnoremap <silent> <ESC> :noh<ESC>

set tabstop     =4
set softtabstop =4
set shiftwidth  =4
set expandtab

"Persist undotree history in /tmp
let s:undodir = "/tmp/.undodir_" . $USER
if !isdirectory(s:undodir)
    call mkdir(s:undodir, "", 0700)
endif
let &undodir=s:undodir
set undofile

set diffopt+=linematch:60
let g:undotree_WindowLayout = 2

autocmd VimEnter * :clearjumps

"When a file has been detected to have been changed outside of Vim
"and it has not been changed inside of Vim, automatically read it again.
:set autoread

nnoremap <silent> <A-up> :wincmd k<CR>
nnoremap <silent> <A-down> :wincmd j<CR>
nnoremap <silent> <A-left> :wincmd h<CR>
nnoremap <silent> <A-right> :wincmd l<CR>
