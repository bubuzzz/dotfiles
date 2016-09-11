set nocompatible 
filetype off 

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'whatyouhide/vim-gotham'

call vundle#end()
filetype plugin indent on

" for some plugin like pug
execute pathogen#infect()

" set up ide 
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab
set expandtab
set number

"color scheme 
syntax on
colorscheme janah 
