set nocompatible 
filetype off 

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'whatyouhide/vim-gotham'
Plugin 'ervandew/supertab'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

call vundle#end()
filetype plugin indent on

" for some plugin like pug
execute pathogen#infect()

" set up ide 
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set cursorline
set cursorcolumn
set expandtab
set number                     " Show current line number
set relativenumber             " Show relative line numbers

" Stop the stupid identation for vim when pasting from other source 
" Thank to https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ""
endfunction
      
" setup auto close 
ino " ""<left>
ino ' ''<left>
ino ( ()<left>
ino [ []<left>
ino { {}<left>
ino {<CR> {<CR>}<ESC>O

" for javascript configuration
autocmd BufNewFile,BufRead *.js,*.es6,*.jsx set filetype=javascript.jsx
autocmd Filetype javascript.jsx setlocal ts=2 sw=2 sts=0 expandtab
autocmd FileType javascript.jsx set colorcolumn=160

" powerline settings 
set rtp+=$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/vim
set rtp+=/usr/local/opt/fzf
set laststatus=2
set t_Co=256

" ultisnipts 
"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"


"color scheme 
syntax on
colorscheme janah 
