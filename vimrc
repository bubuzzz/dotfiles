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
Plugin 'tpope/vim-commentary'
Plugin 'junegunn/vim-easy-align'
Plugin 'jceb/vim-orgmode'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'benmills/vimux'
Plugin 'joshdick/onedark.vim'
Plugin 'SirVer/ultisnips'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'chriskempson/tomorrow-theme'
Plugin 'mxw/vim-jsx'
Plugin 'eshion/vim-sync'
Plugin 'banga/powerline-shell'
Plugin 'kristijanhusak/vim-hybrid-material'
Plugin 'jdkanani/vim-material-theme'

filetype plugin indent on

" for some plugin like pug
execute pathogen#infect()

" set up ide
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab
set number                     " Show current line number
set relativenumber             " Show relative line numbers
" set listchars+=space:␣
" set list

" trim space when saving "
autocmd BufWritePre * %s/\s\+$//e


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
autocmd FileType javascript noremap <buffer> <c-f> :call JsxBeautify()<cr>
autocmd FileType json noremap <buffer> <c-f> :call JsonBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>

autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

"map shift enter to esc"
imap <S-CR> <ESC>

" airline
let g:airline_powerline_fonts = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <c-o> :ZoomToggle<CR>

" save session , making vim become a freaking SublimeText "
function! MakeSession()
  let b:filename = getcwd() . '/session.vim'
  exe "mksession! " . b:filename
endfunction

function! AutoSaveSession()
  let b:filename = getcwd() . '/session.vim'
  if (filereadable(b:filename))
    exe "mksession! " . b:filename
endfunction

function! LoadSession()
  let b:sessionfile = getcwd() . "/session.vim"
  if (filereadable(b:sessionfile))
    exe 'source ' b:sessionfile
  else
    echo "No session loaded."
  endif
endfunction

" Adding automatons for when entering or leaving Vim
au VimEnter * nested :call LoadSession()
au VimLeave * :call AutoSaveSession()
map <c-s> :call MakeSession() <cr>

"----------------------  Color schem  ----------------------"
syntax on

" set background=dark
" colorscheme material-theme
" colorscheme janah

" set background=dark
" colorscheme Tomorrow-Night

set background=dark
colorscheme one

" colorscheme onedark
" colorscheme deep-space
" colorscheme sierra

"----------------------/ Color schem  ----------------------"
