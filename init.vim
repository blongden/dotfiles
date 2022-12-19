set shell=zsh
set nocompatible            " disable compatibility to old-time vi
filetype plugin indent on   "allow auto-indenting depending on file type

set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=2               " number of columns occupied by a tab 
set softtabstop=2           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=2            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
"set spell                  " enable spell check (may need to download language package)
set noswapfile              " disable creating swap file
set backupdir=~/.cache/vim  " Directory to store backup files.
set omnifunc=syntaxcomplete#Complete
set ts=2                    " tab spaces 
set autoread                " auto read changes to open files

" set file position to where it was last edited
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

call plug#begin("~/.vim/plugged")
 Plug 'dracula/vim'
 Plug 'SirVer/ultisnips'
 Plug 'honza/vim-snippets'
 Plug 'scrooloose/nerdtree'
 Plug 'preservim/nerdcommenter'
 Plug 'mhinz/vim-startify'
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 Plug 'vim-airline/vim-airline'
 Plug 'vim-airline/vim-airline-themes'
 Plug 'terrastruct/d2-vim'
 Plug 'nvim-lua/plenary.nvim'
 Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
 Plug 'hashivim/vim-terraform'
 Plug 'github/copilot.vim'
call plug#end()

color dracula

let g:UltiSnipsEditSplit="vertical"

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm(): "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <c-@> coc#refresh()

