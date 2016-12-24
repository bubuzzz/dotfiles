set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'ervandew/supertab'
Plugin 'honza/vim-snippets'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'airblade/vim-gitgutter'
Plugin 'wincent/command-t'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tyrannicaltoucan/vim-deep-space'
Plugin 'haya14busa/incsearch.vim'
Plugin 'alessandroyorba/sierra'
Plugin 'rakr/vim-one'
Plugin 'pangloss/vim-javascript'
Plugin 'mhinz/vim-startify'
Plugin 'scrooloose/nerdcommenter'
Plugin 'junegunn/vim-easy-align'
Plugin 'jceb/vim-orgmode'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'benmills/vimux'
Plugin 'joshdick/onedark.vim'
Plugin 'SirVer/ultisnips'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'chriskempson/tomorrow-theme'

call vundle#end()
filetype plugin indent on

" for some plugin like pug
execute pathogen#infect()

" set up ide
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set cursorcolumn
set expandtab
set number                     " Show current line number
set relativenumber             " Show relative line numbers
" set listchars+=space:␣
" set list
set t_Co=256

" trim space when saving "
autocmd BufWritePre * %s/\s\+$//e

" remove the underline of the hightlight "
function s:SetCursorLine()
    set cursorline
    hi cursorline term=none cterm=none
endfunction
autocmd VimEnter * call s:SetCursorLine()


" set copy/paste from clipboard. from now one, visual mode yy will copy
" directly to clipboard. This need vim compiled with clipboard (vim --version
" | grep clipboard) "
set clipboard=unnamed

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

" set up for the command T"
let g:CommandTWildIgnore="*/node_modules"

" ultisnipts
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" set up for incremental search "
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" Git Guter
let g:gitgutter_enabled = 1

if (has("nvim"))
    set termguicolors
endif


" Map NERDTree "
silent! nmap <C-p> :NERDTreeToggle<CR>
silent! map <F3> :NERDTreeFind<CR>

let g:NERDTreeMapActivateNode="<F3>"
let g:NERDTreeMapPreview="<F4>"

" Kill the capslock when leaving insert mode.
autocmd InsertLeave * set iminsert=0

" JSBeautifier
autocmd FileType jsx noremap <buffer> <c-f> :call JsxBeautify()<cr>
autocmd FileType javascript noremap <buffer> <c-f> :call JsBeautify()<cr>
autocmd FileType json noremap <buffer> <c-f> :call JsonBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>

autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

" airline
let g:airline_powerline_fonts = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" to move around the tab
nnoremap H gT
nnoremap L gt

"----------------------  Color schem  ----------------------"
syntax on
"colorscheme janah

" set background=dark
" colorscheme Tomorrow-Night

set background=dark
colorscheme one

"colorscheme onedark

" colorscheme deep-space

" colorscheme sierra

"----------------------/ Color schem  ----------------------"
