" Matugen dynamic theme for Neovim
" Material You palette with vibrant syntax highlighting and Treesitter coverage
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "matugen"

" Base Editor UI
hi Normal guibg={{ colors.surface.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi NormalNC guibg={{ colors.surface.default.hex }} guifg={{ colors.on_surface_variant.default.hex }}
hi NormalFloat guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi FloatBorder guibg={{ colors.surface_container.default.hex }} guifg={{ colors.outline.default.hex }}
hi FloatTitle guibg={{ colors.surface_container.default.hex }} guifg={{ colors.primary.default.hex }} gui=bold

hi Cursor guibg={{ colors.on_surface.default.hex }} guifg={{ colors.surface.default.hex }}
hi CursorLine guibg={{ colors.surface_container_low.default.hex }} guifg=None
hi CursorColumn guibg={{ colors.surface_container_low.default.hex }} guifg=None
hi ColorColumn guibg={{ colors.surface_container_low.default.hex }} guifg=None

hi LineNr guibg=None guifg={{ colors.outline_variant.default.hex }}
hi CursorLineNr guibg=None guifg={{ colors.primary.default.hex }} gui=bold
hi SignColumn guibg=None guifg={{ colors.outline.default.hex }}
hi VertSplit guibg=None guifg={{ colors.outline_variant.default.hex }}
hi WinSeparator guibg=None guifg={{ colors.outline_variant.default.hex }}
hi EndOfBuffer guibg=None guifg={{ colors.outline_variant.default.hex }}

hi Visual guibg={{ colors.secondary_container.default.hex }} guifg={{ colors.on_secondary_container.default.hex }}
hi Selection guibg={{ colors.secondary_container.default.hex }}

hi Search guibg={{ colors.tertiary_container.default.hex }} guifg={{ colors.on_tertiary_container.default.hex }}
hi IncSearch guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }} gui=bold
hi CurSearch guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }}

hi Pmenu guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi PmenuSel guibg={{ colors.surface_container_highest.default.hex }} guifg={{ colors.primary.default.hex }} gui=bold
hi PmenuSbar guibg={{ colors.surface_container.default.hex }}
hi PmenuThumb guibg={{ colors.outline.default.hex }}

hi StatusLine guibg={{ colors.surface_container_high.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi StatusLineNC guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface_variant.default.hex }}
hi TabLine guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface_variant.default.hex }}
hi TabLineFill guibg={{ colors.surface.default.hex }}
hi TabLineSel guibg={{ colors.surface_container_high.default.hex }} guifg={{ colors.primary.default.hex }} gui=bold
hi Folded guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface_variant.default.hex }}
hi FoldColumn guibg=None guifg={{ colors.outline_variant.default.hex }}
hi MatchParen guibg={{ colors.secondary_container.default.hex }} guifg={{ colors.on_secondary_container.default.hex }} gui=bold

" Core Syntax Highlighting (Material You & Blended Color Tokens)
hi Comment guibg=None guifg={{ colors.outline.default.hex }} gui=italic
hi SpecialComment guibg=None guifg={{ colors.tertiary.default.hex }} gui=italic
hi Todo guibg={{ colors.tertiary_container.default.hex }} guifg={{ colors.on_tertiary_container.default.hex }} gui=bold

hi String guibg=None guifg={{ colors.green.default.hex }}
hi Character guibg=None guifg={{ colors.green.default.hex }}
hi SpecialChar guibg=None guifg={{ colors.teal.default.hex }}

hi Number guibg=None guifg={{ colors.orange.default.hex }}
hi Float guibg=None guifg={{ colors.orange.default.hex }}
hi Boolean guibg=None guifg={{ colors.orange.default.hex }} gui=bold

hi Function guibg=None guifg={{ colors.blue.default.hex }}
hi Identifier guibg=None guifg={{ colors.on_surface.default.hex }}

hi Statement guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi Conditional guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi Repeat guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi Label guibg=None guifg={{ colors.purple.default.hex }}
hi Keyword guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi Exception guibg=None guifg={{ colors.red.default.hex }} gui=bold

hi Type guibg=None guifg={{ colors.yellow.default.hex }}
hi StorageClass guibg=None guifg={{ colors.yellow.default.hex }}
hi Structure guibg=None guifg={{ colors.yellow.default.hex }}
hi Typedef guibg=None guifg={{ colors.yellow.default.hex }}

hi Constant guibg=None guifg={{ colors.orange.default.hex }}
hi PreProc guibg=None guifg={{ colors.magenta.default.hex }}
hi Include guibg=None guifg={{ colors.purple.default.hex }}
hi Define guibg=None guifg={{ colors.magenta.default.hex }}
hi Macro guibg=None guifg={{ colors.magenta.default.hex }}

hi Operator guibg=None guifg={{ colors.primary.default.hex }}
hi Delimiter guibg=None guifg={{ colors.on_surface_variant.default.hex }}
hi Special guibg=None guifg={{ colors.teal.default.hex }}
hi Tag guibg=None guifg={{ colors.red.default.hex }}

" Diagnostics & Feedback
hi Error guibg={{ colors.error_container.default.hex }} guifg={{ colors.on_error_container.default.hex }}
hi WarningMsg guifg={{ colors.yellow.default.hex }}
hi DiagnosticError guifg={{ colors.red.default.hex }}
hi DiagnosticWarn guifg={{ colors.yellow.default.hex }}
hi DiagnosticInfo guifg={{ colors.blue.default.hex }}
hi DiagnosticHint guifg={{ colors.teal.default.hex }}

" Git & Diffs
hi DiffAdd guibg=None guifg={{ colors.green.default.hex }}
hi DiffChange guibg=None guifg={{ colors.yellow.default.hex }}
hi DiffDelete guibg=None guifg={{ colors.red.default.hex }}
hi DiffText guibg={{ colors.surface_container_highest.default.hex }} guifg={{ colors.primary.default.hex }}

" Tree-sitter Syntax Highlighting
hi! link @variable Identifier
hi @variable.builtin guibg=None guifg={{ colors.red.default.hex }}
hi @variable.parameter guibg=None guifg={{ colors.on_surface_variant.default.hex }} gui=italic
hi! link @variable.member Identifier
hi @property guibg=None guifg={{ colors.blue.default.hex }}
hi @field guibg=None guifg={{ colors.blue.default.hex }}

hi @constant guibg=None guifg={{ colors.orange.default.hex }}
hi @constant.builtin guibg=None guifg={{ colors.orange.default.hex }} gui=bold
hi @constant.macro guibg=None guifg={{ colors.magenta.default.hex }}

hi @module guibg=None guifg={{ colors.yellow.default.hex }}
hi @string guibg=None guifg={{ colors.green.default.hex }}
hi @string.escape guibg=None guifg={{ colors.teal.default.hex }}
hi @character guibg=None guifg={{ colors.green.default.hex }}
hi @number guibg=None guifg={{ colors.orange.default.hex }}
hi @boolean guibg=None guifg={{ colors.orange.default.hex }} gui=bold

hi @type guibg=None guifg={{ colors.yellow.default.hex }}
hi @type.builtin guibg=None guifg={{ colors.yellow.default.hex }}
hi @type.definition guibg=None guifg={{ colors.yellow.default.hex }}
hi @constructor guibg=None guifg={{ colors.yellow.default.hex }}

hi @function guibg=None guifg={{ colors.blue.default.hex }}
hi @function.builtin guibg=None guifg={{ colors.blue.default.hex }}
hi @function.method guibg=None guifg={{ colors.blue.default.hex }}
hi @function.macro guibg=None guifg={{ colors.magenta.default.hex }}

hi @keyword guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi @keyword.function guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi @keyword.return guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi @keyword.operator guibg=None guifg={{ colors.purple.default.hex }}
hi @keyword.coroutine guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi @conditional guibg=None guifg={{ colors.purple.default.hex }} gui=bold
hi @repeat guibg=None guifg={{ colors.purple.default.hex }} gui=bold

hi @operator guibg=None guifg={{ colors.primary.default.hex }}
hi @punctuation.delimiter guibg=None guifg={{ colors.on_surface_variant.default.hex }}
hi @punctuation.bracket guibg=None guifg={{ colors.on_surface_variant.default.hex }}
hi @punctuation.special guibg=None guifg={{ colors.teal.default.hex }}

hi @comment guibg=None guifg={{ colors.outline.default.hex }} gui=italic
hi @tag guibg=None guifg={{ colors.red.default.hex }}
hi @tag.attribute guibg=None guifg={{ colors.yellow.default.hex }}
hi @tag.delimiter guibg=None guifg={{ colors.outline.default.hex }}
