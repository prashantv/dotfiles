
set backspace=2         " backspace in insert mode works like normal editor
syntax on               " syntax highlighting
filetype indent on      " activates indenting for files
set autoindent          " auto indenting
set number              " line numbers
set nobackup            " get rid of anoying ~file

set mouse=a

if exists("g:loaded_pathogen")
  execute pathogen#infect()
endif
  execute pathogen#infect()

filetype plugin indent on

if exists("g:loaded_nerdtree")
  " auto open nerdtree when no params
  autocmd vimenter * if !argc() | NERDTree | endif
endif

" :Q really closes everything
command Q qa
colorscheme desert      " colorscheme desert

" smart case sensitivity search
set ignorecase
set smartcase

" color column
set colorcolumn=100

" tabs to spaces
set expandtab
set tabstop=2
set shiftwidth=2

" show and remove trailing whitespace on write
autocmd BufWritePre * :%s/\s\+$//e
:highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
autocmd FileType py setlocal colorcolumn=80
autocmd FileType builddefs setlocal colorcolumn=80
autocmd FileType proto setlocal colorcolumn=80
autocmd FileType javascript setlocal colorcolumn=80
autocmd FileType soy setlocal colorcolumn=80

" javadoc to ctrl+q
map <C-q> :JavaDocPreview<CR>
map <C-Q> :JavaDocPreview<CR>

map <C-H> :JavaSearch
map <C-A-G> :JavaSearchContext<CR>
map <C-S-F> :%JavaFormat<CR>
map <C-S-R> :JavaRename
map <C-F11> :JavaSearchva %<CR>
map <S-A-J> :JavaDocComment<CR>
map <S-A-O> :JavaImportOrganize<CR>
map <S-F2> :JavaDocSearch<CR>
map <F2> :JavaDocPreview<CR>
map <F3> :JavaSearchContext<CR>
map <F4> :JavaHierarchy<CR>



"===========================================
" perforce commands
command! -nargs=* -complete=file PEdit :!g4 edit %

function! s:CheckOutFile()
 if filereadable(expand("%")) && ! filewritable(expand("%"))
   let s:pos = getpos('.')
   let option = confirm("Readonly file, do you want to checkout from p4?"
         \, "&Yes\n&No", 1, "Question")
   if option == 1
     PEdit
   endif
   edit!
   call cursor(s:pos[1:3])
 endif
endfunction
au FileChangedRO * nested :call <SID>CheckOutFile()
