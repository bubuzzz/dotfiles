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
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'airblade/vim-gitgutter'
Plugin 'easymotion/vim-easymotion'
Plugin 'wincent/command-t'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'rakr/vim-one'
Plugin 'tyrannicaltoucan/vim-deep-space'

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
set t_Co=256

" remove the underline of the hightlight "
function s:SetCursorLine()
    set cursorline
    hi cursorline cterm=none ctermbg=darkblue ctermfg=white
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
autocmd FileType javascript.jsx set colorcolumn=160

" powerline settings 
set rtp+=$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/vim
set rtp+=/usr/local/opt/fzf
set laststatus=2
" "set t_Co=256
" set up for the command T"
let g:CommandTWildIgnore="*/node_modules"
" ultisnipts 
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" Git Guter
let g:gitgutter_enabled = 1 

"color scheme 
syntax on
" colorscheme janah 

"" this is for the dark theme 
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
    if (has("nvim"))
        "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
        let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    endif
    "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
    if (has("termguicolors"))
        set termguicolors
    endif
endif

" set background=dark " for the dark version
" colorscheme one
"
set background=dark
colorscheme deep-space
