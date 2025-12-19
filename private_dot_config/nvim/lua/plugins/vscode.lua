if not vim.g.vscode then
  return {}
end

local enabled = {
  "LazyVim",
  "dial.nvim",
  "flit.nvim",
  "lazy.nvim",
  "leap.nvim",
  "mini.ai",
  "mini.comment",
  "mini.move",
  "mini.pairs",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  "snacks.nvim",
  "ts-comments.nvim",
  "vim-repeat",
  "yanky.nvim",
}

local Config = require("lazy.core.config")
local vscode = require("vscode")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end
vim.g.snacks_animate = false

-- Add some vscode specific keymaps
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymapsDefaults",
  callback = function()
    -- Helper function to create VSCode action keymaps
    local function map(mode, lhs, action, opts)
      opts = opts or {}
      opts.silent = opts.silent ~= false
      vim.keymap.set(mode, lhs, function()
        vscode.action(action)
      end, opts)
    end

    ----------------------------------------------------------------------------
    -- File Explorer
    ----------------------------------------------------------------------------
    map("n", "<leader>e", "workbench.view.explorer", { desc = "Explorer" })
    map("n", "<leader>E", "workbench.files.action.focusFilesExplorer", { desc = "Focus Explorer" })
    map("n", "<leader>fe", "workbench.view.explorer", { desc = "Explorer" })
    map("n", "<leader>fE", "workbench.files.action.focusFilesExplorer", { desc = "Focus Explorer" })

    ----------------------------------------------------------------------------
    -- Find Files / Search
    ----------------------------------------------------------------------------
    map("n", "<leader><space>", "workbench.action.quickOpen", { desc = "Find Files" })
    map("n", "<leader>ff", "workbench.action.quickOpen", { desc = "Find Files" })
    map("n", "<leader>fF", "workbench.action.quickOpen", { desc = "Find Files (cwd)" })
    map("n", "<leader>.", "workbench.action.quickOpen", { desc = "Find Files" })
    map("n", "<leader>fr", "workbench.action.openRecent", { desc = "Recent Files" })
    map("n", "<leader>fR", "workbench.action.openRecent", { desc = "Recent Files (cwd)" })
    map("n", "<leader>fn", "workbench.action.files.newUntitledFile", { desc = "New File" })
    map("n", "<leader>fc", "workbench.action.openSettings", { desc = "Find Config File" })
    map("n", "<leader>fg", "workbench.action.findInFiles", { desc = "Find in Files" })
    map("n", "<leader>fp", "workbench.action.openRecent", { desc = "Recent Projects" })

    ----------------------------------------------------------------------------
    -- Buffers
    ----------------------------------------------------------------------------
    map("n", "<leader>,", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "Switch Buffer" })
    map("n", "<leader>fb", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "Buffers" })
    map("n", "<leader>fB", "workbench.action.showAllEditors", { desc = "All Buffers" })
    map("n", "<leader>bb", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "Switch Buffer" })
    map("n", "<leader>`", "workbench.action.openPreviousRecentlyUsedEditor", { desc = "Alternate Buffer" })
    map("n", "<leader>bd", "workbench.action.closeActiveEditor", { desc = "Close Buffer" })
    map("n", "<leader>bD", "workbench.action.closeActiveEditor", { desc = "Close Buffer (Force)" })
    map("n", "<leader>bo", "workbench.action.closeOtherEditors", { desc = "Close Other Buffers" })
    map("n", "<leader>bl", "workbench.action.closeEditorsToTheRight", { desc = "Close Buffers to Right" })
    map("n", "<leader>bp", "editor.action.clipboardPasteAction", { desc = "Paste to Buffer" })
    map("n", "<leader>br", "workbench.action.closeEditorsToTheLeft", { desc = "Close Buffers to Left" })
    map("n", "<leader>bP", "workbench.action.pinEditor", { desc = "Pin Buffer" })

    -- Buffer navigation
    map("n", "[b", "workbench.action.previousEditor", { desc = "Previous Buffer" })
    map("n", "]b", "workbench.action.nextEditor", { desc = "Next Buffer" })
    map("n", "[B", "workbench.action.firstEditorInGroup", { desc = "First Buffer" })
    map("n", "]B", "workbench.action.lastEditorInGroup", { desc = "Last Buffer" })
    map("n", "<S-h>", "workbench.action.previousEditor", { desc = "Previous Buffer" })
    map("n", "<S-l>", "workbench.action.nextEditor", { desc = "Next Buffer" })

    ----------------------------------------------------------------------------
    -- Search / Grep
    ----------------------------------------------------------------------------
    map("n", "<leader>/", "workbench.action.findInFiles", { desc = "Grep" })
    map("n", "<leader>sg", "workbench.action.findInFiles", { desc = "Grep" })
    map("n", "<leader>sG", "workbench.action.findInFiles", { desc = "Grep (cwd)" })
    map("n", "<leader>sw", "editor.action.addSelectionToNextFindMatch", { desc = "Search Word" })
    map("n", "<leader>sW", "editor.action.addSelectionToNextFindMatch", { desc = "Search Word (cwd)" })
    map("v", "<leader>sw", "editor.action.addSelectionToNextFindMatch", { desc = "Search Selection" })
    map("v", "<leader>sW", "editor.action.addSelectionToNextFindMatch", { desc = "Search Selection (cwd)" })
    map("n", "<leader>sr", "workbench.action.replaceInFiles", { desc = "Replace in Files" })
    map("n", "<leader>sR", "workbench.action.replaceInFiles", { desc = "Replace in Files (cwd)" })
    map("n", "<leader>sb", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "Search Buffers" })
    map("n", "<leader>sB", "workbench.action.showAllEditors", { desc = "Search All Buffers" })
    map("n", "<leader>sc", "workbench.action.showCommands", { desc = "Commands" })
    map("n", "<leader>sC", "workbench.action.showAllCommands", { desc = "All Commands" })
    map("n", "<leader>sd", "workbench.actions.view.problems", { desc = "Diagnostics" })
    map("n", "<leader>sD", "workbench.actions.view.problems", { desc = "Workspace Diagnostics" })
    map("n", "<leader>sh", "workbench.action.showAllCommands", { desc = "Help" })
    map("n", "<leader>sH", "workbench.action.showAllCommands", { desc = "Help Pages" })
    map("n", "<leader>sk", "workbench.action.openGlobalKeybindings", { desc = "Keymaps" })
    map("n", "<leader>sm", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "Jump to Mark" })
    map("n", "<leader>sM", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "Man Pages" })

    ----------------------------------------------------------------------------
    -- Command Palette
    ----------------------------------------------------------------------------
    map("n", "<leader>:", "workbench.action.showCommands", { desc = "Command Palette" })

    ----------------------------------------------------------------------------
    -- LSP
    ----------------------------------------------------------------------------
    map("n", "<leader>cl", "workbench.action.showAllSymbols", { desc = "Lsp Info" })
    map("n", "gd", "editor.action.revealDefinition", { desc = "Go to Definition" })
    map("n", "gr", "editor.action.goToReferences", { desc = "References" })
    map("n", "gI", "editor.action.goToImplementation", { desc = "Go to Implementation" })
    map("n", "gy", "editor.action.goToTypeDefinition", { desc = "Go to Type Definition" })
    map("n", "gD", "editor.action.revealDeclaration", { desc = "Go to Declaration" })
    map("n", "K", "editor.action.showHover", { desc = "Hover" })
    map("n", "gK", "editor.action.triggerParameterHints", { desc = "Signature Help" })
    map("i", "<c-k>", "editor.action.triggerParameterHints", { desc = "Signature Help" })

    -- Code actions
    map("n", "<leader>ca", "editor.action.quickFix", { desc = "Code Action" })
    map("v", "<leader>ca", "editor.action.quickFix", { desc = "Code Action" })
    map("n", "<leader>cA", "editor.action.sourceAction", { desc = "Source Action" })
    map("n", "<leader>cr", "editor.action.rename", { desc = "Rename" })
    map("n", "<leader>cR", "editor.action.rename", { desc = "Rename File" })
    map("n", "<leader>cf", "editor.action.formatDocument", { desc = "Format Document" })
    map("v", "<leader>cf", "editor.action.formatSelection", { desc = "Format Selection" })
    map("n", "<leader>cF", "editor.action.formatDocument", { desc = "Format Document (Force)" })
    map("n", "<leader>co", "editor.action.organizeImports", { desc = "Organize Imports" })
    map("n", "<leader>cc", "editor.action.triggerSuggest", { desc = "Code Completion" })
    map("n", "<leader>cC", "editor.action.showContextMenu", { desc = "Code Context Menu" })

    -- Symbols
    map("n", "<leader>ss", "workbench.action.gotoSymbol", { desc = "Document Symbols" })
    map("n", "<leader>sS", "workbench.action.showAllSymbols", { desc = "Workspace Symbols" })

    -- Next/Previous reference
    map("n", "]]", "editor.action.wordHighlight.next", { desc = "Next Reference" })
    map("n", "[[", "editor.action.wordHighlight.prev", { desc = "Previous Reference" })

    ----------------------------------------------------------------------------
    -- Diagnostics / Problems
    ----------------------------------------------------------------------------
    map("n", "<leader>xx", "workbench.actions.view.problems", { desc = "Problems" })
    map("n", "<leader>xX", "workbench.actions.view.problems", { desc = "Workspace Problems" })
    map("n", "<leader>xl", "workbench.actions.view.problems", { desc = "Location List" })
    map("n", "<leader>xL", "workbench.actions.view.problems", { desc = "Workspace Location List" })
    map("n", "<leader>xq", "workbench.actions.view.problems", { desc = "Quickfix List" })
    map("n", "<leader>xQ", "workbench.actions.view.problems", { desc = "Workspace Quickfix" })
    map("n", "<leader>xt", "workbench.actions.view.problems", { desc = "Todo" })
    map("n", "<leader>xT", "workbench.actions.view.problems", { desc = "Todo/Fix/Fixme" })

    -- Navigate diagnostics
    map("n", "]d", "editor.action.marker.nextInFiles", { desc = "Next Diagnostic" })
    map("n", "[d", "editor.action.marker.prevInFiles", { desc = "Previous Diagnostic" })
    map("n", "]e", "editor.action.marker.nextInFiles", { desc = "Next Error" })
    map("n", "[e", "editor.action.marker.prevInFiles", { desc = "Previous Error" })
    map("n", "]w", "editor.action.marker.nextInFiles", { desc = "Next Warning" })
    map("n", "[w", "editor.action.marker.prevInFiles", { desc = "Previous Warning" })

    -- Navigate quickfix
    map("n", "]q", "editor.action.marker.nextInFiles", { desc = "Next Quickfix" })
    map("n", "[q", "editor.action.marker.prevInFiles", { desc = "Previous Quickfix" })

    ----------------------------------------------------------------------------
    -- Windows / Splits
    ----------------------------------------------------------------------------
    map("n", "<leader>-", "workbench.action.splitEditorDown", { desc = "Split Below" })
    map("n", "<leader>|", "workbench.action.splitEditor", { desc = "Split Right" })
    map("n", "<leader>wd", "workbench.action.closeActiveEditor", { desc = "Close Window" })
    map("n", "<leader>wm", "workbench.action.toggleEditorWidths", { desc = "Maximize Window" })

    -- Window navigation (using Ctrl+hjkl)
    map("n", "<C-h>", "workbench.action.focusLeftGroup", { desc = "Focus Left Window" })
    map("n", "<C-j>", "workbench.action.focusBelowGroup", { desc = "Focus Below Window" })
    map("n", "<C-k>", "workbench.action.focusAboveGroup", { desc = "Focus Above Window" })
    map("n", "<C-l>", "workbench.action.focusRightGroup", { desc = "Focus Right Window" })

    -- Resize windows
    map("n", "<C-Up>", "workbench.action.increaseViewHeight", { desc = "Increase Height" })
    map("n", "<C-Down>", "workbench.action.decreaseViewHeight", { desc = "Decrease Height" })
    map("n", "<C-Left>", "workbench.action.decreaseViewWidth", { desc = "Decrease Width" })
    map("n", "<C-Right>", "workbench.action.increaseViewWidth", { desc = "Increase Width" })

    ----------------------------------------------------------------------------
    -- Tabs
    ----------------------------------------------------------------------------
    map("n", "<leader><tab>l", "workbench.action.lastEditorInGroup", { desc = "Last Tab" })
    map("n", "<leader><tab>o", "workbench.action.closeOtherEditors", { desc = "Close Other Tabs" })
    map("n", "<leader><tab>f", "workbench.action.firstEditorInGroup", { desc = "First Tab" })
    map("n", "<leader><tab><tab>", "workbench.action.files.newUntitledFile", { desc = "New Tab" })
    map("n", "<leader><tab>]", "workbench.action.nextEditor", { desc = "Next Tab" })
    map("n", "<leader><tab>d", "workbench.action.closeActiveEditor", { desc = "Close Tab" })
    map("n", "<leader><tab>[", "workbench.action.previousEditor", { desc = "Previous Tab" })

    ----------------------------------------------------------------------------
    -- Git
    ----------------------------------------------------------------------------
    map("n", "<leader>gs", "workbench.view.scm", { desc = "Git Status" })
    map("n", "<leader>gS", "workbench.view.scm", { desc = "Git Stage" })
    map("n", "<leader>gc", "git.commit", { desc = "Git Commit" })
    map("n", "<leader>gC", "git.commitAll", { desc = "Git Commit All" })
    map("n", "<leader>gb", "gitlens.toggleFileBlame", { desc = "Git Blame" })
    map("n", "<leader>gB", "gitlens.toggleFileBlame", { desc = "Git Browse" })
    map("n", "<leader>gd", "git.openChange", { desc = "Diff" })
    map("n", "<leader>gD", "git.openAllChanges", { desc = "Diff All" })
    map("n", "<leader>gf", "git.fetch", { desc = "Git Fetch" })
    map("n", "<leader>gl", "git.viewHistory", { desc = "Git Log" })
    map("n", "<leader>gL", "gitlens.showCommitSearch", { desc = "Git Log (cwd)" })
    map("n", "<leader>gp", "git.pull", { desc = "Git Pull" })
    map("n", "<leader>gP", "git.push", { desc = "Git Push" })
    map("n", "<leader>gr", "git.revertSelectedRanges", { desc = "Git Revert" })
    map("n", "<leader>gR", "git.revertChange", { desc = "Git Reset" })
    map("n", "<leader>gi", "workbench.action.git.viewIgnored", { desc = "Git Ignored" })
    map("n", "<leader>gI", "git.init", { desc = "Git Init" })
    map("n", "<leader>gY", "git.copyRemoteUrl", { desc = "Copy Remote URL" })

    -- Git hunks
    map("n", "]h", "workbench.action.editor.nextChange", { desc = "Next Hunk" })
    map("n", "[h", "workbench.action.editor.previousChange", { desc = "Previous Hunk" })
    map("n", "<leader>ghp", "editor.action.dirtydiff.previous", { desc = "Preview Hunk" })
    map("n", "<leader>ghr", "git.revertSelectedRanges", { desc = "Reset Hunk" })
    map("n", "<leader>ghs", "git.stageSelectedRanges", { desc = "Stage Hunk" })
    map("n", "<leader>ghu", "git.unstageSelectedRanges", { desc = "Unstage Hunk" })

    ----------------------------------------------------------------------------
    -- Debug
    ----------------------------------------------------------------------------
    map("n", "<leader>da", "workbench.action.debug.selectandstart", { desc = "Debug: Select and Start" })
    map("n", "<leader>db", "editor.debug.action.toggleBreakpoint", { desc = "Toggle Breakpoint" })
    map("n", "<leader>dB", "editor.debug.action.conditionalBreakpoint", { desc = "Conditional Breakpoint" })
    map("n", "<leader>dc", "workbench.action.debug.continue", { desc = "Continue" })
    map("n", "<leader>dC", "workbench.action.debug.runToCursor", { desc = "Run to Cursor" })
    map("n", "<leader>dg", "workbench.action.debug.run", { desc = "Go to Line (No Execute)" })
    map("n", "<leader>di", "workbench.action.debug.stepInto", { desc = "Step Into" })
    map("n", "<leader>dj", "workbench.action.debug.callStackDown", { desc = "Down Stack" })
    map("n", "<leader>dk", "workbench.action.debug.callStackUp", { desc = "Up Stack" })
    map("n", "<leader>dl", "workbench.action.debug.start", { desc = "Run Last" })
    map("n", "<leader>do", "workbench.action.debug.stepOver", { desc = "Step Over" })
    map("n", "<leader>dO", "workbench.action.debug.stepOut", { desc = "Step Out" })
    map("n", "<leader>dp", "workbench.action.debug.pause", { desc = "Pause" })
    map("n", "<leader>dP", "editor.debug.action.toggleInlineBreakpoint", { desc = "Inline Breakpoint" })
    map("n", "<leader>dr", "workbench.action.debug.restart", { desc = "Restart" })
    map("n", "<leader>ds", "workbench.action.debug.start", { desc = "Start" })
    map("n", "<leader>dt", "workbench.action.debug.stop", { desc = "Stop" })
    map("n", "<leader>dw", "workbench.debug.action.toggleRepl", { desc = "Debug Console" })
    map("n", "<leader>du", "workbench.view.debug", { desc = "Debug UI" })
    map("n", "<leader>de", "editor.debug.action.selectionToWatch", { desc = "Eval" })

    ----------------------------------------------------------------------------
    -- Testing
    ----------------------------------------------------------------------------
    map("n", "<leader>tr", "testing.runAtCursor", { desc = "Run Test" })
    map("n", "<leader>tt", "testing.runCurrentFile", { desc = "Run File" })
    map("n", "<leader>tT", "testing.runAll", { desc = "Run All Tests" })
    map("n", "<leader>td", "testing.debugAtCursor", { desc = "Debug Test" })
    map("n", "<leader>tD", "testing.debugCurrentFile", { desc = "Debug File" })
    map("n", "<leader>ts", "testing.reRunLastRun", { desc = "Run Last" })
    map("n", "<leader>tS", "testing.stopCurrentRun", { desc = "Stop" })
    map("n", "<leader>to", "testing.showMostRecentOutput", { desc = "Output" })
    map("n", "<leader>tO", "testing.openOutputPeek", { desc = "Output Peek" })

    ----------------------------------------------------------------------------
    -- Terminal
    ----------------------------------------------------------------------------
    map("n", "<leader>ft", "workbench.action.terminal.toggleTerminal", { desc = "Terminal" })
    map("n", "<leader>fT", "workbench.action.terminal.new", { desc = "New Terminal" })
    map("n", "<c-/>", "workbench.action.terminal.toggleTerminal", { desc = "Toggle Terminal" })
    map("n", "<c-_>", "workbench.action.terminal.toggleTerminal", { desc = "Toggle Terminal" })

    ----------------------------------------------------------------------------
    -- UI Toggles
    ----------------------------------------------------------------------------
    map("n", "<leader>ub", "editor.action.toggleMinimap", { desc = "Toggle Minimap" })
    map("n", "<leader>uc", "workbench.action.toggleCenteredLayout", { desc = "Toggle Centered Layout" })
    map("n", "<leader>uC", "workbench.action.selectTheme", { desc = "Select Colorscheme" })
    map("n", "<leader>ud", "workbench.actions.view.problems", { desc = "Toggle Diagnostics" })
    map("n", "<leader>uf", "editor.action.toggleWordWrap", { desc = "Toggle Format on Save" })
    map("n", "<leader>uF", "editor.action.toggleWordWrap", { desc = "Toggle Format on Save (Global)" })
    map("n", "<leader>ug", "workbench.action.toggleSidebarVisibility", { desc = "Toggle Sidebar" })
    map("n", "<leader>uh", "editor.action.toggleHighContrast", { desc = "Toggle Inlay Hints" })
    map("n", "<leader>ui", "editor.action.inspectTMScopes", { desc = "Inspect Pos" })
    map("n", "<leader>uI", "editor.action.inspectTMScopes", { desc = "Inspect Tree" })
    map("n", "<leader>ul", "editor.action.toggleRenderWhitespace", { desc = "Toggle Whitespace" })
    map("n", "<leader>uL", "editor.action.toggleRenderWhitespace", { desc = "Toggle Relative Line Numbers" })
    map("n", "<leader>un", "notifications.clearAll", { desc = "Dismiss Notifications" })
    map("n", "<leader>uS", "workbench.action.toggleStatusbarVisibility", { desc = "Toggle Statusbar" })
    map("n", "<leader>uw", "editor.action.toggleWordWrap", { desc = "Toggle Word Wrap" })
    map("n", "<leader>uZ", "workbench.action.toggleEditorWidths", { desc = "Maximize" })
    map("n", "<leader>uz", "workbench.action.toggleZenMode", { desc = "Zen Mode" })

    ----------------------------------------------------------------------------
    -- Sessions / Projects
    ----------------------------------------------------------------------------
    map("n", "<leader>qS", "workbench.action.openRecent", { desc = "Select Session/Project" })
    map("n", "<leader>qq", "workbench.action.closeWindow", { desc = "Quit" })

    ----------------------------------------------------------------------------
    -- Notifications
    ----------------------------------------------------------------------------
    map("n", "<leader>snd", "notifications.clearAll", { desc = "Dismiss All" })
    map("n", "<leader>snh", "notifications.showList", { desc = "Notification History" })
    map("n", "<leader>snl", "notifications.showList", { desc = "Last Notification" })

    ----------------------------------------------------------------------------
    -- Save
    ----------------------------------------------------------------------------
    map("n", "<C-s>", "workbench.action.files.save", { desc = "Save" })
    map("i", "<C-s>", "workbench.action.files.save", { desc = "Save" })
    map("v", "<C-s>", "workbench.action.files.save", { desc = "Save" })

    ----------------------------------------------------------------------------
    -- Move lines (Alt+j/k)
    ----------------------------------------------------------------------------
    map("n", "<A-j>", "editor.action.moveLinesDownAction", { desc = "Move Line Down" })
    map("n", "<A-k>", "editor.action.moveLinesUpAction", { desc = "Move Line Up" })
    map("i", "<A-j>", "editor.action.moveLinesDownAction", { desc = "Move Line Down" })
    map("i", "<A-k>", "editor.action.moveLinesUpAction", { desc = "Move Line Up" })
    map("v", "<A-j>", "editor.action.moveLinesDownAction", { desc = "Move Lines Down" })
    map("v", "<A-k>", "editor.action.moveLinesUpAction", { desc = "Move Lines Up" })

    ----------------------------------------------------------------------------
    -- Commenting (use VSCode's toggle comment)
    ----------------------------------------------------------------------------
    map("n", "gcc", "editor.action.commentLine", { desc = "Toggle Comment" })
    map("v", "gc", "editor.action.commentLine", { desc = "Toggle Comment" })
    map("n", "gco", "editor.action.addCommentLine", { desc = "Add Comment Below" })
    map("n", "gcO", "editor.action.addCommentLine", { desc = "Add Comment Above" })

    ----------------------------------------------------------------------------
    -- Folding
    ----------------------------------------------------------------------------
    map("n", "za", "editor.toggleFold", { desc = "Toggle Fold" })
    map("n", "zA", "editor.toggleFold", { desc = "Toggle Fold Recursively" })
    map("n", "zc", "editor.fold", { desc = "Close Fold" })
    map("n", "zC", "editor.foldRecursively", { desc = "Close Fold Recursively" })
    map("n", "zo", "editor.unfold", { desc = "Open Fold" })
    map("n", "zO", "editor.unfoldRecursively", { desc = "Open Fold Recursively" })
    map("n", "zM", "editor.foldAll", { desc = "Close All Folds" })
    map("n", "zR", "editor.unfoldAll", { desc = "Open All Folds" })

    ----------------------------------------------------------------------------
    -- Miscellaneous
    ----------------------------------------------------------------------------
    map("n", "<esc>", "cancelSelection", { desc = "Clear hlsearch" })
    map("n", "<leader>K", "editor.action.showHover", { desc = "Keywordprg" })
    map("n", "<leader>l", "workbench.view.extensions", { desc = "Extensions (Lazy)" })
    map("n", "<leader>L", "workbench.view.extensions", { desc = "Extensions Info" })
  end,
})


return {
  {
    "snacks.nvim",
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
    },
  },
  {
    "LazyVim/LazyVim",
    config = function(_, opts)
      opts = opts or {}
      -- disable the colorscheme
      opts.colorscheme = function() end
      require("lazyvim").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
