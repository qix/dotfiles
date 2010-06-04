set nocompatible
set backupdir=~/.vim/backups//
set directory=~/.vim/backups//


set guioptions-=T
set wildmenu

" File types
filetype on
filetype plugin on

" Indentation
filetype indent on
set autoindent
set smartindent
set cin
set shiftround



syntax on
set background=dark

set shiftwidth=2
set tabstop=2
set softtabstop=2

colorscheme slate
set autochdir
set showcmd            " Show (partial) command in status line.
"set showmatch          " Show matching brackets.
set ignorecase         " Do case insensitive matching
set smartcase          " Do smart case matching
set incsearch          " Incremental search
set autowrite          " Automatically save before commands like :next and :make
set hidden             " Hide buffers when they are abandoned
set mouse=a            " Enable mouse usage (all modes)

if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set scrolloff=5
set nopaste

let php_sql_query=1
let php_htmlInStrings=1



"no t j
"no n k
"no s l

function TabOrComplete()
	let col = col('.')-1
	if !col || getline('.')[col-1] !~ '\k'
		return "\<tab>"
	else
		return "\<C-N>"
	endif
endfunction

" enable eclipse style moving of lines
nmap <M-j> mz:m+<CR>`z==
nmap <M-k> mz:m-2<CR>`z==
imap <M-j> <Esc>:m+<CR>==gi
imap <M-k> <Esc>:m-2<CR>==gi
vmap <M-j> :m'>+<CR>gv=`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<CR>gv=`>my`<mzgv`yo`z


inoremap <Tab> <C-R>=TabOrComplete()<CR>

let mapleader = ","
map <silent> <leader>w :w<CR>
map <silent> <leader>d :silent :NERDTree /www/habo/habo.org.za/db<CR>
map <silent> <leader>h :silent :NERDTree /www/habo/habo.org.za<CR>
map <silent> <leader>l :silent :NERDTree /www/lusion<CR>
map <silent> <leader>r :silent :NERDTree /www/lusion/lusion.co.za/ahs<CR>
map <silent> <leader>s :silent :NERDTree /www/snapbill<CR>
map <silent> <leader>t :silent :NERDTree /www/thraph<CR>
map <silent> <leader>w :silent :NERDTree /www<CR>

map <silent> <S-Enter> :silent :confirm w<CR>

map <silent> <c-s> :silent :confirm w<CR>
map <silent> <c-y> :silent :!~/scripts/firefox/reload<CR>
map <silent> <c-d> :silent :confirm w<CR>:!~/scripts/firefox/reload<CR>
map <silent> <c-f> :silent !!fortune<CR>
map <silent> <c-u> <c-s>:!~/scripts/run_save<CR>

map € :silent :NERDTree

imap <c-s> <c-o><c-s>
imap <c-u> <c-o><c-u>
imap <c-d> <c-o><c-s><c-o><c-y>

imap <c-x> </<Plug>ragtagHtmlComplete
imap <c-9> {

" I dont like the comments system much
set comments= 
set makeprg=php\ -l\ %
set errorformat=%m\ in\ %f\ on\ line\ %l

"map <silent> <c-m> :make<cr><cr>
"imap <c-m> <c-o><c-m>

