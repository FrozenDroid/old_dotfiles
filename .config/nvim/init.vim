call plug#begin('~/.vim/plugged')

" UI Plugins
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Git stuff
Plug 'airblade/vim-gitgutter'

" Misc
Plug 'moll/vim-bbye'

" Syntax support
Plug 'rust-lang/rust.vim'
Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }

" Autocompletion 
Plug 'roxma/nvim-completion-manager'

call plug#end()

""""""""""""""
"" Settings
""

set cursorline
set hidden
set hlsearch
set ignorecase
set incsearch
set list
set number
set ruler
set showcmd
set noshowmode
set smartcase
set splitbelow
set splitright
set termguicolors
set title
set undofile
set wildmenu
set wrap

set signcolumn=yes
set background=dark
set backspace=start,eol,indent
set completeopt=menu,menuone,longest,noselect
set encoding=utf8
set fillchars+=vert:/
set foldcolumn=1
set foldmethod=marker
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set history=1000
set laststatus=0
set listchars+=nbsp:%
set listchars+=tab:]-
set listchars+=trail:#
set mouse=a
set numberwidth=5
set pastetoggle=<F11>
set scrolloff=5
set showtabline=2
set tabline=%!CustomTabLine()
set tags+=.tags
set textwidth=120
set timeoutlen=400
set undolevels=1000
set updatetime=1500
set viewoptions=cursor,folds
set wildchar=<Tab>
set wildmode=longest,list
set winminwidth=20
set winwidth=80

" Indentation
set autoindent
set expandtab
set shiftwidth=4
set tabstop=4

colors tomorrow-night
syntax on
filetype plugin indent on

""""""""""""""
"" Automatically close brackets and such
""

ino " ""<left>
ino ' ''<left>
ino ( ()<left>
ino [ []<left>
ino { {}<left>
ino {<CR> {<CR>}<ESC>O
ino {;<CR> {<CR>};<ESC>O

""""""""""""""
"" Mappings
""

nnoremap    <silent> <C-s>      :w<CR>
vnoremap    <silent> <C-s>      <C-c>:w<CR>
inoremap    <silent> <C-s>      <C-c>:w<CR>

" Make home ignore starting whitespaces
nnoremap    <silent> <Home>     ^
vnoremap    <silent> <Home>     ^
inoremap    <silent> <Home>     <C-o>^

" ^X to close the current buffer
nnoremap    <silent> <C-x>      :Bdelete<CR>
vnoremap    <silent> <C-x>      <C-c>:Bdelete<CR>

" ^J/^K for tab switching
nnoremap    <silent> <C-k>      :bn<CR>
nnoremap    <silent> <C-j>      :bp<CR>

map <C-n> :NERDTreeToggle<CR>



" Required for operations modifying multiple buffers like rename.

"""""""""""""""""""""""""
"" Plugin configuration
""

let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'stable', 'rls'],
    \ }

" Gitgutter config

let g:gitgutter_sign_added            = '--'
let g:gitgutter_sign_modified         = '--'
let g:gitgutter_sign_modified_removed = '__'
let g:gitgutter_sign_removed          = '__'

" Racer
let g:racer_experimental_completer = 1

nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>i

""""""""""""""
"" Functions
""

" Custom tab line function
function! CustomTabLine()
    let s = '%#TabLine# '

    let numtabs = tabpagenr('$')
    if numtabs > 1
        let s .= numtabs . ' tabs! (Only one supported) '
    endif

    let listedbufs = {}
    let listedbufi = 1

    for n in filter(range(1, bufnr('$')), 'buflisted(v:val)')
        let listedbufs[n] = listedbufi
        let listedbufi += 1

        " TODO: Handle cases > 9

        let bufname  = substitute(bufname(n), $HOME, '~', '')
        let dirpath  = substitute(bufname, '[^/]\+/\?$', '', '')
        let filename = strpart(bufname, strlen(dirpath))

        let hilight     = (n == bufnr('')) ? '%#TabLineActive#'     : '%#TabLineInactive#'
        let hilightbold = (n == bufnr('')) ? '%#TabLineActiveBold#' : '%#TabLineInactiveBold#'

        let leftbound  = ''
        let rightbound = '  '

        let indicator = (getbufvar(n, '&modified')) ? '%#TabLineModified#! ' : ''

        let s .= hilightbold . leftbound . indicator . hilight . dirpath . hilightbold . filename . rightbound . '%#TabLine# '
    endfor

    " Set up maps to jump to buffer with Alt + number
    " TODO: This should probably go somewhere else
    if len(listedbufs) > 0
        if has_key(listedbufs, bufnr(''))
            let curbufnr = listedbufs[bufnr('')]
        else
            let curbufnr = 0
        endif

        " Previous buffers
        for n in filter(range(1, bufnr('') - 1), 'buflisted(v:val)')
            let d = curbufnr - listedbufs[n]
            execute 'nnoremap <buffer> <A-' . listedbufs[n] . '> :' . d . 'bp<CR>'
            execute 'inoremap <buffer> <A-' . listedbufs[n] . '> <C-c>:' . d . 'bp<CR>'
        endfor

        " Unmap current
        execute 'nnoremap <buffer> <A-' . curbufnr . '> <Nop>'
        execute 'inoremap <buffer> <A-' . curbufnr . '> <Nop>'

        " Next buffers
        for n in filter(range(bufnr('') + 1, bufnr('$')), 'buflisted(v:val)')
            let d = listedbufs[n] - curbufnr
            execute 'nnoremap <buffer> <A-' . listedbufs[n] . '> :' . d . 'bn<CR>'
            execute 'inoremap <buffer> <A-' . listedbufs[n] . '> <C-c>:' . d . 'bn<CR>'
        endfor
    endif

    return s
endfunction
