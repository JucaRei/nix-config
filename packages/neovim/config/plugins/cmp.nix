{
  plugins = {
    # Completion
    cmp-nvim-lsp.enable = true;
    cmp-fuzzy-buffer.enable = true;
    cmp-fuzzy-path.enable = true;
    cmp-zsh.enable = true;
    cmp-calc.enable = true;
    cmp-cmdline.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;
    cmp-spell.enable = true;
    cmp_luasnip.enable = true;
  };
  extraConfigLua = ''
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if not cmp_status_ok then
        return
      end

      local snip_status_ok, luasnip = pcall(require, "luasnip")
      if not snip_status_ok then
        return
      end

      -- require("luasnip/loaders/from_vscode").lazy_load()

      local check_backspace = function()
        local col = vim.fn.col(".") - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
      end

      -- 󰇊 󰇊 󰇊 󰇊  󰇊 some other good icons
      local kind_icons = {
        Text = "󰇊",
        Method = "m",
        Function = "󰇊",
        Constructor = "",
        Field = "",
        Variable = "󰇊",
        Class = "󰇊",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "󰇊",
        Enum = "",
        Keyword = "󰇊",
        Snippet = "",
        Color = "󰇊",
        File = "󰇊",
        Reference = "",
        Folder = "󰇊",
        EnumMember = "",
        Constant = "󰇊",
        Struct = "",
        Event = "",
        Operator = "󰇊",
        TypeParameter = "󰇊",
      }
      -- find more here: https://www.nerdfonts.com/cheat-sheet

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = {
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          -- Accept currently selected item. If none selected, `select` first item.
          -- Set `select` to `false` to only confirm explicitly selected items.
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            vim_item.menu = ({
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "conjure" },
          { name = "neorg" },
          --[[ { name = "dynamic" }, ]]
          { name = "latex_symbols" },
          { name = "orgmode" },
          { name = "path" },
          cmp.config.sources({
            { name = "nvim_lsp_document_symbol" },
          }, {
            { name = "buffer" },
          }),
          -- { name = "copilot" },
          { name = "nvim_lua" },
          { name = "calc" },
          { name = "buffer" },
          {
            name = "spell",
            option = {
              keep_all_entries = false,
              enable_in_context = function()
                return true
              end,
            },
          },
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        window = {
          documentation = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      vim.cmd([[
      " gray
      highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
      " blue
      highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
      highlight! link CmpItemAbbrMatchFuzzy CmpItemAbbrMatch
      " light blue
      highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
      highlight! link CmpItemKindInterface CmpItemKindVariable
      highlight! link CmpItemKindText CmpItemKindVariable
      " pink
      highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
      highlight! link CmpItemKindMethod CmpItemKindFunction
      " front
      highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
      highlight! link CmpItemKindProperty CmpItemKindKeyword
      highlight! link CmpItemKindUnit CmpItemKindKeyword
      ]])

    --  local Date = require("cmp_dynamic.utils.date")
    --
    --  require("cmp_dynamic").register({
    --    {
    --      label = "today",
    --      insertText = 1,
    --      cb = {
    --        function()
    --          return os.date("%Y/%m/%d")
    --        end,
    --      },
    --    },
    --    {
    --      label = "next Monday",
    --      insertText = 1,
    --      cb = {
    --        function()
    --          return Date.new():add_date(7):day(1):format("%Y/%m/%d")
    --        end,
    --      },
    --      resolve = true, -- default: false
    --    },
    --  })
  '';
}
