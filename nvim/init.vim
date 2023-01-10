set number
set relativenumber
set mouse=a
syntax enable
set encoding=utf-8
set showmatch
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set termguicolors
set t_Co=256
set scrolloff=999
set ignorecase
set clipboard+=unnamedplus
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

" Plugin config
call plug#begin('~/.config/nvim/plugins')
Plug 'romgrk/barbar.nvim'
Plug 'mcchrish/zenbones.nvim'
Plug 'rktjmp/lush.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'lambdalisue/suda.vim'
Plug 'tpope/vim-commentary'
Plug 'mhinz/vim-startify'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'brenoprata10/nvim-highlight-colors'
call plug#end()

" Color scheme config
set background=dark
colorscheme zenbones

" Shortcuts
noremap k gk
noremap <Up> gk
noremap j gj
noremap <Down> gj
nnoremap <silent> <C-f> :NvimTreeToggle<CR>
nnoremap <silent> <C-1> <Cmd>BufferGoto 1<CR>
nnoremap <silent> <C-2> <Cmd>BufferGoto 2<CR>
nnoremap <silent> <C-3> <Cmd>BufferGoto 3<CR>
nnoremap <silent> <C-4> <Cmd>BufferGoto 4<CR>
nnoremap <silent> <C-5> <Cmd>BufferGoto 5<CR>
nnoremap <silent> <C-6> <Cmd>BufferGoto 6<CR>
nnoremap <silent> <C-7> <Cmd>BufferGoto 7<CR>
nnoremap <silent> <C-8> <Cmd>BufferGoto 8<CR>
nnoremap <silent> <C-9> <Cmd>BufferGoto 9<CR>
nnoremap <silent> <C-0> <Cmd>BufferLast<CR>
nnoremap <silent> <C-c> <Cmd>BufferClose<CR>
nnoremap <silent> <C-s> <Cmd>:w<CR>:SSave! current<CR>
lua << EOF
-- Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = {'python', 'javascript', 'r', 'html', 'css', 
                      'bash', 'c', 'json', 'lua', 'vim', 'vue'};
  highlight = {
	enable = true,
	additional_vim_regex_highlighting = false,
  },
  incremental_selection = { enable = true; },
  indent = { enable = false; },
}

-- Bottom line
require('lualine').setup()

-- Indent lines
vim.opt.list = true

require("indent_blankline").setup {
  show_current_context = true,
  show_current_context_start = true,
}

-- Barbar config
require'bufferline'.setup {
  closable = true,
  clickable = true,
  icons = true,
  icon_separator_active = '▎',
  icon_separator_inactive = '▎',
  icon_close_tab = '',
  icon_close_tab_modified = '●',
  insert_at_end = true,
}

-- Nvim tree
require("nvim-tree").setup({
  view = {
    relativenumber = true,
    mappings = {
      list = {
        { key = "l", action = "edit" },
        { key = "y", action = "copy" },
        { key = "DD", action = "remove" },
      },
    },
  },
})

EOF

" Starting welcome screen
hi StartifyHeader ctermfg=Red

let g:startify_custom_header = [
  \'    ███████████   █████ █████  █████████  ██████████',
  \'   ░░███░░░░░███ ░░███ ░░███  ███░░░░░███░░███░░░░░█',
  \'    ░███    ░███  ░░███ ███  ░███    ░░░  ░███  █ ░ ',
  \'    ░██████████    ░░█████   ░░█████████  ░██████   ',
  \'    ░███░░░░░███    ░░███     ░░░░░░░░███ ░███░░█   ',
  \'    ░███    ░███     ░███     ███    ░███ ░███ ░   █',
  \'    █████   █████    █████   ░░█████████  ██████████',
  \'   ░░░░░   ░░░░░    ░░░░░     ░░░░░░░░░  ░░░░░░░░░░ ',
  \]
let g:startify_lists = [
  \ { 'type': 'dir',       'header': ['   pwd '. getcwd()] },
  \ { 'type': 'sessions',  'header': ['   sessions']       },
  \ ]

" Write as super ryse
let g:suda#prompt = 'Masterkey: '

" https://github.com/neoclide/coc.nvim/wiki/Language-servers
set encoding=utf-8
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for apply code actions at the cursor position.
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer.
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for apply refactor code actions.
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" Set colors
lua require("nvim-highlight-colors").turnOn()
