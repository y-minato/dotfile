" release autogroup in MyAutoCmd
augroup MyAutoCmd
  autocmd!
augroup END

" 前時代的スクリーンベルを無効化
set t_vb=
set novisualbell
set number
set nowrap
set nobackup
set noswapfile
"set expandtab

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

let s:noplugin = 0
let s:bundle_root = expand('~/.vim/bundle')
let s:neobundle_root = s:bundle_root . '/neobundle.vim'
if !isdirectory(s:neobundle_root) || v:version < 702
    " NeoBundleが存在しない、もしくはVimのバージョンが古い場合はプラグインを一切
    " 読み込まない
    let s:noplugin = 1
else
    " NeoBundleを'runtimepath'に追加し初期化を行う
    if has('vim_starting')
        execute "set runtimepath+=" . s:neobundle_root
    endif
    call neobundle#rc(s:bundle_root)

    " NeoBundle自身をNeoBundleで管理させる
    NeoBundleFetch 'Shougo/neobundle.vim'

    " 非同期通信を可能にする
    " 'build'が指定されているのでインストール時に自動的に
    " 指定されたコマンドが実行され vimproc がコンパイルされる
    NeoBundle "Shougo/vimproc", {
        \ "build": {
        \   "windows"   : "make -f make_mingw32.mak",
        \   "cygwin"    : "make -f make_cygwin.mak",
        \   "mac"       : "make -f make_mac.mak",
        \   "unix"      : "make -f make_unix.mak",
        \ }}

    NeoBundle 'Shougo/vimshell'


    " Insertモードに入るまではneocompleteはロードされない
    NeoBundleLazy 'Shougo/neocomplete.vim', {
        \ "autoload": {"insert": 1}}
    " neocompleteのhooksを取得
    let s:hooks = neobundle#get_hooks("neocomplete.vim")
    " neocomplete用の設定関数を定義。下記関数はneocompleteロード時に実行される
    function! s:hooks.on_source(bundle)
        let g:acp_enableAtStartup = 0
        let g:neocomplete#enable_smart_case = 1

        " 補完候補の一番先頭を選択状態にする
        "let g:neocomplcache_enable_auto_select = 1
        " CamelCase補完
        let g:neocomplcache_enable_camel_case_completion = 1
        " Underbar補完
        let g:neocomplcache_enable_underbar_completion = 1

        let g:neocomplcache_dictionary_filetype_lists = {
          \ 'java' : '~/.vim/dict/java.dict'
          \ }

    endfunction

    " 'GundoToggle'が呼ばれるまでロードしない
    NeoBundleLazy 'sjl/gundo.vim', {
        \ "autoload": {"commands": ["GundoToggle"]}}
    " '<Plug>TaskList'というマッピングが呼ばれるまでロードしない
    NeoBundleLazy 'vim-scripts/TaskList.vim', {
        \ "autoload": {"mappings": ['<Plug>TaskList']}}
    " HTMLが開かれるまでロードしない
    NeoBundleLazy 'mattn/emmet-vim', {
        \ "autoload": {"filetypes": ['html', 'jsp']}}

    nnoremap <Leader>g :GundoToggle<CR>

    NeoBundle "thinca/vim-template"
    " テンプレート中に含まれる特定文字列を置き換える
    autocmd MyAutoCmd User plugin-template-loaded call s:template_keywords()
    function! s:template_keywords()
        silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
        silent! %s/<+FILENAME+>/\=expand('%:r')/g
    endfunction
    " テンプレート中に含まれる'<+CURSOR+>'にカーソルを移動
    autocmd MyAutoCmd User plugin-template-loaded
        \   if search('<+CURSOR+>')
        \ |   silent! execute 'normal! "_da>'
        \ | endif


    NeoBundleLazy "Shougo/unite.vim", {
          \ "autoload": {
          \   "commands": ["Unite", "UniteWithBufferDir"]
          \ }}
    NeoBundleLazy 'h1mesuke/unite-outline', {
          \ "autoload": {
          \   "unite_sources": ["outline"],
          \ }}

    nnoremap [unite] <Nop>
    nmap U [unite]
    nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
    nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
    nnoremap <silent> [unite]r :<C-u>Unite register<CR>
    nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
    nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
    nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
    nnoremap <silent> [unite]t :<C-u>Unite tag<CR>
    nnoremap <silent> [unite]w :<C-u>Unite window<CR>
    nnoremap <silent> [unite]s :<C-u>Unite snippet<CR>
    nnoremap <silent> [unite]r :<C-u>Unite ruby/require<CR>
    let s:hooks = neobundle#get_hooks("unite.vim")
    function! s:hooks.on_source(bundle)
      " start unite in insert mode
      let g:unite_enable_start_insert = 1
      let g:unite_source_file_ignore_pattern='target/.*'
      let g:unite_source_grep_default_opts = '-iRHn'
      " use vimfiler to open directory
      call unite#custom_default_action("source/bookmark/directory", "vimfiler")
      call unite#custom_default_action("directory", "vimfiler")
      call unite#custom_default_action("directory_mru", "vimfiler")
      autocmd MyAutoCmd FileType unite call s:unite_settings()
      function! s:unite_settings()
        imap <buffer> <Esc><Esc> <Plug>(unite_exit)
        nmap <buffer> <Esc> <Plug>(unite_exit)
        nmap <buffer> <C-n> <Plug>(unite_select_next_line)
        nmap <buffer> <C-p> <Plug>(unite_select_previous_line)
      endfunction

       " escape２回で終了
       au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
       au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
       " ウィンドウを分割して開く
       au FileType unite nnoremap <silent> <buffer> <expr> <C-x> unite#do_action('split')
       au FileType unite inoremap <silent> <buffer> <expr> <C-x> unite#do_action('split')
       " ウィンドウを縦に分割して開く
       au FileType unite nnoremap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
       au FileType unite inoremap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
    endfunction



    NeoBundleLazy "Shougo/vimfiler", {
      \ "depends": ["Shougo/unite.vim"],
      \ "autoload": {
      \   "commands": ["VimFilerTab", "VimFiler", "VimFilerExplorer"],
      \   "mappings": ['<Plug>(vimfiler_switch)'],
      \   "explorer": 1,
      \ }}
    nnoremap <Leader>e :VimFilerExplorer<CR>
    " close vimfiler automatically when there are only vimfiler open
    autocmd MyAutoCmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') | q | endif
    let s:hooks = neobundle#get_hooks("vimfiler")
    function! s:hooks.on_source(bundle)
      "セーフモードを無効にした状態で起動する
      let g:vimfiler_safe_mode_by_default = 0
      let g:vimfiler_enable_auto_cd = 1
  
      " .から始まるファイルおよび.pycで終わるファイルを不可視パターンに
      let g:vimfiler_ignore_pattern = "\%(^\..*\|\.pyc$\)"
      let g:vimfiler_as_default_explorer = 1

      " vimfiler specific key mappings
      autocmd MyAutoCmd FileType vimfiler call s:vimfiler_settings()
      function! s:vimfiler_settings()
        " ^^ to go up
        nmap <buffer> ^^ <Plug>(vimfiler_switch_to_parent_directory)
        " use R to refresh
        nmap <buffer> R <Plug>(vimfiler_redraw_screen)
        " overwrite C-l
        nmap <buffer> <C-l> <C-w>l
      endfunction
    endfunction


    NeoBundleLazy "mattn/gist-vim", {
          \ "depends": ["mattn/webapi-vim"],
          \ "autoload": {
          \   "commands": ["Gist"],
          \ }}

    " vim-fugitiveは'autocmd'多用してるっぽくて遅延ロード不可
    NeoBundle "tpope/vim-fugitive"
    NeoBundleLazy "gregsexton/gitv", {
          \ "depends": ["tpope/vim-fugitive"],
          \ "autoload": {
          \   "commands": ["Gitv"],
          \ }}


    NeoBundle 'tpope/vim-surround'
    NeoBundle 'vim-scripts/Align'
    NeoBundle 'vim-scripts/YankRing.vim'


    if has('lua') && v:version >= 703 && has('patch885')
        NeoBundleLazy "Shougo/neocomplete.vim", {
            \ "autoload": {
            \   "insert": 1,
            \ }}
        let g:neocomplete#enable_at_startup = 1
        let s:hooks = neobundle#get_hooks("neocomplete.vim")
        function! s:hooks.on_source(bundle)
            let g:acp_enableAtStartup = 0
            let g:neocomplet#enable_smart_case = 1
        endfunction
    else
        NeoBundleLazy "Shougo/neocomplcache.vim", {
            \ "autoload": {
            \   "insert": 1,
            \ }}
        let g:neocomplcache_enable_at_startup = 1
        let s:hooks = neobundle#get_hooks("neocomplcache.vim")
        function! s:hooks.on_source(bundle)
            let g:acp_enableAtStartup = 0
            let g:neocomplcache_enable_smart_case = 1
            " NeoComplCacheを有効化
            " NeoComplCacheEnable 
        endfunction
    endif


    NeoBundle "Shougo/neosnippet.vim"
    let s:hooks = neobundle#get_hooks("neosnippet.vim")
    function! s:hooks.on_source(bundle)
      " Plugin key-mappings.
      imap <C-k>     <Plug>(neosnippet_expand_or_jump)
      smap <C-k>     <Plug>(neosnippet_expand_or_jump)
      xmap <C-k>     <Plug>(neosnippet_expand_target)
      " SuperTab like snippets behavior.
      imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: pumvisible() ? "\<C-n>" : "\<TAB>"
      smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: "\<TAB>"
      " For snippet_complete marker.
      if has('conceal')
        set conceallevel=2 concealcursor=i
      endif
      " Enable snipMate compatibility feature.
      let g:neosnippet#enable_snipmate_compatibility = 1
      " Tell Neosnippet about the other snippets
      let g:neosnippet#snippets_directory=s:bundle_root . '~./vim/snippets'
    endfunction

    NeoBundle "nathanaelkane/vim-indent-guides"
    let s:hooks = neobundle#get_hooks("vim-indent-guides")
    function! s:hooks.on_source(bundle)
      let g:indent_guides_guide_size = 1
      IndentGuidesEnable
    endfunction


    NeoBundle "thinca/vim-quickrun"

    NeoBundleLazy 'majutsushi/tagbar', {
          \ "autload": {
          \   "commands": ["TagbarToggle"],
          \ },
          \ "build": {
          \   "mac": "brew install ctags",
          \ }}
    nmap <Leader>t :TagbarToggle<CR>



    NeoBundle "scrooloose/syntastic", {
          \ "build": {
          \   "mac": ["pip install flake8", "npm -g install coffeelint"],
          \   "unix": ["pip install flake8", "npm -g install coffeelint"],
          \ }}


    NeoBundleLazy "davidhalter/jedi-vim", {
          \ "autoload": {
          \   "filetypes": ["python", "python3", "djangohtml"],
          \ },
          \ "build": {
          \   "mac": "pip install jedi",
          \   "unix": "pip install jedi",
          \ }}
    let s:hooks = neobundle#get_hooks("jedi-vim")
    function! s:hooks.on_source(bundle)
      " jediにvimの設定を任せると'completeopt+=preview'するので
      " 自動設定機能をOFFにし手動で設定を行う
      let g:jedi#auto_vim_configuration = 0
      " 補完の最初の項目が選択された状態だと使いにくいためオフにする
      let g:jedi#popup_select_first=0
      let g:jedi#popup_on_dot=0
      " quickrunと被るため大文字に変更
      let g:jedi#rename_command = '<Leader>R'
      " gundoと被るため大文字に変更
      "let g:jedi#goto_command = '<Leader>P'
    endfunction

    " 起動<c-p>
    " vsplit open <c-v>
    " split open <c-x>
    NeoBundle 'kien/ctrlp.vim'
    let g:ctrlp_custom_ignore = { "file": ".*target\/.*$" }
    "let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_working_path_mode = 'w'

    " </ を入力したときに自動的に補完してくれる。
    "NeoBundle 'docunext/closetag.vim'
    " スネークケース、キャメルケースの変換など crc crs
    NeoBundle 'tpope/vim-abolish'
    NeoBundle 'fuenor/qfixgrep.git'

    "for java
    NeoBundleLazy "java_getset.vim", {
          \ "autoload": {
          \   "filetypes": ["java"],
          \ }}

    " for javascript
    NeoBundleLazy "JavaScript-syntax", {
          \ "autoload": {
          \   "filetypes": ["js"],
          \ }}

    NeoBundleLazy "pangloss/vim-javascript", {
          \ "autoload": {
          \   "filetypes": ["js"],
          \ }}

"    NeoBundleLazy "teramako/jscomplete-vim", {
    NeoBundle "teramako/jscomplete-vim"
    let g:jscomplete_use = ['dom', 'moz', 'es6th']

    "gxでブラウザ起動。なぜもっと早く気がつかなかった。。
    NeoBundle 'open-browser.vim'
    let g:netrw_nogx = 1 " disable netrw's gx mapping.
    nmap gx <Plug>(openbrowser-smart-search)
    vmap gx <Plug>(openbrowser-smart-search)


    NeoBundle 'Lokaltog/vim-easymotion'
    let g:EasyMotion_leader_key="'"



    NeoBundle 'mbbill/undotree'
    " undotree.vim
    " http://vimblog.com/blog/2012/09/02/undotree-dot-vim-display-your-undo-history-in-a-graph/
    " https://github.com/r1chelt/dotfiles/blob/master/.vimrc
    nmap <Leader>u :UndotreeToggle<CR>
    let g:undotree_SetFocusWhenToggle = 1
    let g:undotree_SplitLocation = 'topleft'
    let g:undotree_SplitWidth = 35
    let g:undotree_diffAutoOpen = 1
    let g:undotree_diffpanelHeight = 25
    let g:undotree_RelativeTimestamp = 1
    let g:undotree_TreeNodeShape = '*'
    let g:undotree_HighlightChangedText = 1
    let g:undotree_HighlightSyntax = "UnderLined"


    NeoBundle 'w0ng/vim-hybrid'
    NeoBundle 'nanotech/jellybeans.vim'
    NeoBundle 'Wombat'
    colorscheme desert
    NeoBundle 'itchyny/lightline.vim'
    let g:lightline = {
            \ 'mode_map': {'c': 'NORMAL'},
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
            \ },
            \ 'component_function': {
            \   'modified': 'MyModified',
            \   'readonly': 'MyReadonly',
            \   'fugitive': 'MyFugitive',
            \   'filename': 'MyFilename',
            \   'fileformat': 'MyFileformat',
            \   'filetype': 'MyFiletype',
            \   'fileencoding': 'MyFileencoding',
            \   'mode': 'MyMode'
            \ }
            \ }
    
    function! MyModified()
      return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
    endfunction
    
    function! MyReadonly()
      return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
    endfunction
    
    function! MyFilename()
      return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
            \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
            \  &ft == 'unite' ? unite#get_status_string() :
            \  &ft == 'vimshell' ? vimshell#get_status_string() :
            \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
            \ ('' != MyModified() ? ' ' . MyModified() : '')
    endfunction

    function! MyFugitive()
      try
        if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
          return fugitive#head()
        endif
      catch
      endtry
      return ''
    endfunction

    function! MyFileformat()
      return winwidth(0) > 70 ? &fileformat : ''
    endfunction
    
    function! MyFiletype()
      return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
    endfunction

    function! MyFileencoding()
      return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
    endfunction

    NeoBundleLazy "skammer/vim-css-color", {
          \ "autoload": {
          \   "filetypes": ["css"],
          \ }}
    let g:cssColorVimDoNotMessMyUpdatetime = 1

    NeoBundleLazy "derekwyatt/vim-scala", {
          \ "autoload": {
          \   "filetypes": ["scala"],
          \ }}

    function! MyMode()
      return winwidth(0) > 60 ? lightline#mode() : ''
    endfunction

    NeoBundle "vcscommand.vim"
    let howm_dir = '~/howmdir'
    let howm_fileencoding = 'utf-8'
    let howm_fielformat = 'unix'
    let QFixHowm_FileType = 'markdown'
    let QFixHowm_Title = '#'
    let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
    let QFixHowm_DiaryFile = 'diary/%Y/%m/%Y-%m-%d-000000.howm'

    NeoBundle 'fuenor/qfixhowm'
    NeoBundle 'szw/vim-tags'


    " for ruby
    NeoBundleLazy 'ruby-matchit', {
        \ "autoload": {"filetypes": ['ruby']}}
    
    NeoBundle 'rhysd/unite-ruby-require.vim'

    NeoBundleLazy 'rhysd/neco-ruby-keyword-args' , {
        \ "autoload": {"filetypes": ['ruby']}}

    NeoBundleLazy 'Shougo/neocomplcache-rsense', {
        \ "autoload": {"filetypes": ['ruby']}}

    let s:bundle = neobundle#get("neocomplcache-rsense")
    function! s:bundle.hooks.on_source(bundle)
      let g:neocomplcache_enable_at_startup = 1
      let g:neocomplcache#sources#rsense#home_directory = '/usr/local/Cellar/rsense/0.3'

      if !exists('g:neocomplcache_omni_patterns')
        let g:neocomplcache_omni_patterns = {}
      endif
      let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
    endfunction
    unlet s:bundle

    " for tag
    NeoBundle  "tsukkee/unite-tag"
    
    NeoBundle "vim-scripts/taglist.vim"
    let Tlist_Exit_OnlyWindow = 1                      " taglistのウインドウだけならVimを閉じる
    map <silent> <leader>l :TlistToggle<CR>      " \lでtaglistウインドウを開いたり閉じたり出来るショートカット

    " for textobj
    NeoBundle "kana/vim-textobj-user"
    NeoBundle "h1mesuke/textobj-wiw"

    NeoBundleLazy "rhysd/vim-textobj-ruby" , {
        \ "autoload": {"filetypes": ['ruby']}}


    NeoBundleLazy "wesleyche/SrcExpl", {
        \ "autoload": {"mappings": [' :SrcExplToggle']}}
    NeoBundleLazy "wesleyche/Trinity", {
        \ "autoload": {"mappings": [' :SrcExplToggle']}}

    nmap <F8> :SrcExplToggle<CR>
    let s:bundle = neobundle#get("SrcExpl")
    function! s:bundle.hooks.on_source(bundle)
      let g:SrcExpl_winHeight = 8
      let g:SrcExpl_refreshTime = 100
      let g:SrcExpl_pluginList = [ 
            \ "__Tag_List__"
        \ ] 
    endfunction
    unlet s:bundle

    " インストールされていないプラグインのチェックおよびダウンロード
    NeoBundleCheck
endif

" ファイルタイププラグインおよびインデントを有効化
" これはNeoBundleによる処理が終了したあとに呼ばなければならない
"filetype plugin indent on

" %コマンドのジャンプを拡張
:source $VIMRUNTIME/macros/matchit.vim
:let b:match_words='\<if\>:\<endif\>,(:),{:},[:],\<begin\>:\<end\>'
:let b:match_ignorecase = 1

"  カーソル行をハイライト
set cursorline
" カレントウィンドウにのみ罫線を引く
augroup cch
autocmd! cch
autocmd WinLeave * set nocursorline
autocmd WinEnter,BufRead * set cursorline
augroup END
:hi clear CursorLine
:hi CursorLine gui=underline
"highlight CursorLine ctermbg=glay guibg=glay

" ywで単語のどこにいても全単語をヤンクできる。
noremap <silent>yw yiw

" ヤンクした文字列をcyで置換
nnoremap <silent> cy ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>

" コマンド履歴を開く
nnoremap <F5> <Esc>q:
" 検索履歴を開く
nnoremap <F6> <Esc>q/

" ステータスラインにファイル名を常に表示
":set statusline=%F%m%r%h%w\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
:set laststatus=2 

"現バッファの差分表示。
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

" windowsのサイズ変更
noremap <C-j> <C-w>-
noremap <C-k> <C-w>+
noremap <C-h> <C-w><
noremap <C-l> <C-w>>

" 最後に編集された位置に移動
nnoremap Gb '[
nnoremap Gp ']


" タグジャンプ & バック
nnoremap <F2> <C-W><C-]>
nnoremap <F3> <C-]>
nnoremap <F4> <C-t>


"set tabstop=4
"set expandtab
"set shiftwidth=4

syntax on

set backspace=indent,eol,start

set splitright
