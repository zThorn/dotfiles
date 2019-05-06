set nocompatible
filetype plugin indent on
syntax on

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'altercation/vim-colors-solarized'
Plugin 'VundleVim/Vundle.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'zchee/deoplete-jedi' "Async python autocomplete
Plugin 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins' }
Plugin 'nvie/vim-flake8'
Plugin 'scrooloose/nerdtree'
Plugin 'morhetz/gruvbox'
Plugin 'vim-airline/vim-airline'
Plugin 'chrisbra/csv.vim'
call vundle#end()

map <C-b> :NERDTreeToggle<CR>

colorscheme gruvbox
set background=dark
set guifont=Hack:h12:cANSI
set backspace=indent,eol,start
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set undofile
set undodir=~/.vim/undodir
set number
set cursorline
set showmatch
set incsearch
set hlsearch
set colorcolumn=81,161,241
let s:undos = split(globpath(&undodir, '*'), "\n")
call filter(s:undos, 'getftime(v:val( < localtime() - (60 * 60 * 24 * 90)')
call map(s:undos, 'delete(v:val)')

let g:deoplete#enable_at_startup = 1
let g:jedi#completions_enabled = 0
let g:rehash256 = 1
