" Matugen dynamic theme for Neovim
" Material You palette with vibrant syntax highlighting and Treesitter coverage
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "matugen"

" Base Editor UI
hi Normal guibg=#111318 guifg=#e1e2e9
hi NormalNC guibg=#111318 guifg=#c3c6cf
hi NormalFloat guibg=#1d2024 guifg=#e1e2e9
hi FloatBorder guibg=#1d2024 guifg=#8d9199
hi FloatTitle guibg=#1d2024 guifg=#a5c8ff gui=bold

hi Cursor guibg=#e1e2e9 guifg=#111318
hi CursorLine guibg=#191c20 guifg=None
hi CursorColumn guibg=#191c20 guifg=None
hi ColorColumn guibg=#191c20 guifg=None

hi LineNr guibg=None guifg=#43474e
hi CursorLineNr guibg=None guifg=#a5c8ff gui=bold
hi SignColumn guibg=None guifg=#8d9199
hi VertSplit guibg=None guifg=#43474e
hi WinSeparator guibg=None guifg=#43474e
hi EndOfBuffer guibg=None guifg=#43474e

hi Visual guibg=#3d4758 guifg=#d8e3f8
hi Selection guibg=#3d4758

hi Search guibg=#553f5d guifg=#f7d8ff
hi IncSearch guibg=#a5c8ff guifg=#00315e gui=bold
hi CurSearch guibg=#a5c8ff guifg=#00315e

hi Pmenu guibg=#1d2024 guifg=#e1e2e9
hi PmenuSel guibg=#32353a guifg=#a5c8ff gui=bold
hi PmenuSbar guibg=#1d2024
hi PmenuThumb guibg=#8d9199

hi StatusLine guibg=#282a2f guifg=#e1e2e9
hi StatusLineNC guibg=#1d2024 guifg=#c3c6cf
hi TabLine guibg=#1d2024 guifg=#c3c6cf
hi TabLineFill guibg=#111318
hi TabLineSel guibg=#282a2f guifg=#a5c8ff gui=bold
hi Folded guibg=#1d2024 guifg=#c3c6cf
hi FoldColumn guibg=None guifg=#43474e
hi MatchParen guibg=#3d4758 guifg=#d8e3f8 gui=bold

" Core Syntax Highlighting (Material You & Blended Color Tokens)
hi Comment guibg=None guifg=#8d9199 gui=italic
hi SpecialComment guibg=None guifg=#dabde2 gui=italic
hi Todo guibg=#553f5d guifg=#f7d8ff gui=bold

hi String guibg=None guifg=#91d5ad
hi Character guibg=None guifg=#91d5ad
hi SpecialChar guibg=None guifg=#80d4d7

hi Number guibg=None guifg=#ffb59d
hi Float guibg=None guifg=#ffb59d
hi Boolean guibg=None guifg=#ffb59d gui=bold

hi Function guibg=None guifg=#a7c8ff
hi Identifier guibg=None guifg=#e1e2e9

hi Statement guibg=None guifg=#c9bfff gui=bold
hi Conditional guibg=None guifg=#c9bfff gui=bold
hi Repeat guibg=None guifg=#c9bfff gui=bold
hi Label guibg=None guifg=#c9bfff
hi Keyword guibg=None guifg=#c9bfff gui=bold
hi Exception guibg=None guifg=#fbb0d8 gui=bold

hi Type guibg=None guifg=#d5c871
hi StorageClass guibg=None guifg=#d5c871
hi Structure guibg=None guifg=#d5c871
hi Typedef guibg=None guifg=#d5c871

hi Constant guibg=None guifg=#ffb59d
hi PreProc guibg=None guifg=#c9bfff
hi Include guibg=None guifg=#c9bfff
hi Define guibg=None guifg=#c9bfff
hi Macro guibg=None guifg=#c9bfff

hi Operator guibg=None guifg=#a5c8ff
hi Delimiter guibg=None guifg=#c3c6cf
hi Special guibg=None guifg=#80d4d7
hi Tag guibg=None guifg=#fbb0d8

" Diagnostics & Feedback
hi Error guibg=#93000a guifg=#ffdad6
hi WarningMsg guifg=#d5c871
hi DiagnosticError guifg=#fbb0d8
hi DiagnosticWarn guifg=#d5c871
hi DiagnosticInfo guifg=#a7c8ff
hi DiagnosticHint guifg=#80d4d7

" Git & Diffs
hi DiffAdd guibg=None guifg=#91d5ad
hi DiffChange guibg=None guifg=#d5c871
hi DiffDelete guibg=None guifg=#fbb0d8
hi DiffText guibg=#32353a guifg=#a5c8ff

" Tree-sitter Syntax Highlighting
hi! link @variable Identifier
hi @variable.builtin guibg=None guifg=#fbb0d8
hi @variable.parameter guibg=None guifg=#c3c6cf gui=italic
hi! link @variable.member Identifier
hi @property guibg=None guifg=#a7c8ff
hi @field guibg=None guifg=#a7c8ff

hi @constant guibg=None guifg=#ffb59d
hi @constant.builtin guibg=None guifg=#ffb59d gui=bold
hi @constant.macro guibg=None guifg=#c9bfff

hi @module guibg=None guifg=#d5c871
hi @string guibg=None guifg=#91d5ad
hi @string.escape guibg=None guifg=#80d4d7
hi @character guibg=None guifg=#91d5ad
hi @number guibg=None guifg=#ffb59d
hi @boolean guibg=None guifg=#ffb59d gui=bold

hi @type guibg=None guifg=#d5c871
hi @type.builtin guibg=None guifg=#d5c871
hi @type.definition guibg=None guifg=#d5c871
hi @constructor guibg=None guifg=#d5c871

hi @function guibg=None guifg=#a7c8ff
hi @function.builtin guibg=None guifg=#a7c8ff
hi @function.method guibg=None guifg=#a7c8ff
hi @function.macro guibg=None guifg=#c9bfff

hi @keyword guibg=None guifg=#c9bfff gui=bold
hi @keyword.function guibg=None guifg=#c9bfff gui=bold
hi @keyword.return guibg=None guifg=#c9bfff gui=bold
hi @keyword.operator guibg=None guifg=#c9bfff
hi @keyword.coroutine guibg=None guifg=#c9bfff gui=bold
hi @conditional guibg=None guifg=#c9bfff gui=bold
hi @repeat guibg=None guifg=#c9bfff gui=bold

hi @operator guibg=None guifg=#a5c8ff
hi @punctuation.delimiter guibg=None guifg=#c3c6cf
hi @punctuation.bracket guibg=None guifg=#c3c6cf
hi @punctuation.special guibg=None guifg=#80d4d7

hi @comment guibg=None guifg=#8d9199 gui=italic
hi @tag guibg=None guifg=#fbb0d8
hi @tag.attribute guibg=None guifg=#d5c871
hi @tag.delimiter guibg=None guifg=#8d9199
