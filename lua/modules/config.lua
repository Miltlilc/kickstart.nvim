local M = {}
local home = os.getenv 'HOME'

local function root_dir(markers)
    return vim.fs.dirname(vim.fs.find(markers, { upward = true })[1])
end

function M.auto_save()
    return {
        execution_message = {
            dim = 0.7, -- dim the color of `message`
            cleaning_interval = 250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
            message = function() -- message to print on save
                return 'Saved'
            end,
        },
    }
end

function M.lsp_signature()
    return {
        bind = true,
        padding = '',
        handler_opts = {
            border = 'rounded',
        },
        hint_prefix = '󱄑 ',
    }
end

function M.spring_boot()
    vim.g.spring_boot = {
        jdt_extensions_path = home .. '/.config/jdtls/spring/extension/jars',
        jdt_extensions_jars = {
            'commons-lsp-extensions.jar',
            'io.projectreactor.reactor-core.jar',
            'jdt-ls-commons.jar',
            'jdt-ls-extension.jar',
            'org.reactivestreams.reactive-streams.jar',
            'sts-gradle-tooling.jar',
            'xml-ls-extension.jar',
        },
    }
    return {
        filetypes = { 'java', 'yaml', 'yml', 'jproperties' },
        ls_path = home .. '/.config/jdtls/spring/extension/language-server',
        jdtls_name = 'jdtls',
        log_file = nil,
        java_cmd = nil, -- by default will try to get java 17+ path by using JAVA_HOME. If set, this will use the value here as the java command
    }
end

function M.jdtls()
    local config = {}
    local project_name = vim.fn.fnamemodify(root_dir { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }, ':p:h:t')

    local capabilities = require('jdtls').extendedClientCapabilities
    capabilities.resolveAdditionalTextEditsSupport = true

    local settings = {
        java = {
            contentProvider = { preferred = 'fernflower' },
            jdt = {
                ls = { vmargs = '-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx4G -Xms100m' },
            },
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = 'interactive' },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            format = {
                enabled = true,
                settings = {
                    profile = 'GoogleStyle',
                    url = home .. '/.config/nvim/.java-google-formatter.xml',
                },
            },
        },
        signatureHelp = { enabled = true },
        extendedClientCapabilities = capabilities,
        sources = {
            organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
            },
        },
    }

    config.bundles = {}
    vim.list_extend(config.bundles, require('spring_boot').java_extensions())
    vim.list_extend(config.bundles, vim.split(vim.fn.glob(home .. '/.config/jdtls/decomp/server/*.jar'), '\n'))

    config.cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. home .. '/.config/jdtls/plugins/lombok.jar',
        '-Xmx4g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        home .. '/.config/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',
        '-configuration',
        home .. '/.config/jdtls/config',
        '-data',
        home .. '/.config/jdtls/workspaces/' .. project_name,
    }

    config.capabilities = capabilities
    config.init_options = {
        bundles = config.bundles,
        extendedClientCapabilities = capabilities,
    }

    config.flags = {
        allow_incremental_sync = true,
        server_side_fuzzy_completion = true,
    }

    config.jdtls_plugins = { 'spring-boot-tools' }

    config.on_init = function(client, _)
        client.notify('workspace/didChangeConfiguration', { settings = settings })
    end
    config.on_attach = function(client, buffer)
        require('lsp_signature').on_attach(M.lsp_signature(), buffer)
    end

    config.capabilities = vim.tbl_deep_extend('force', config.capabilities, require('cmp_nvim_lsp').default_capabilities())
    return config
end

function M.null_ls()
    local null_ls = require 'null-ls'
    return {
        sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.completion.spell,
            null_ls.builtins.formatting.google_java_format,
            null_ls.builtins.diagnostics.codespell,
            null_ls.builtins.formatting.codespell,
            null_ls.builtins.formatting.jq,
            null_ls.builtins.formatting.uncrustify,
            null_ls.builtins.formatting.mdformat,
        },
    }
end

M.treesitter = {
    ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'java', 'javascript', 'yaml', 'typescript', 'tsx' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
}

M.mini = {
    ai = {
        n_lines = 500,
    },
    surround = {},
    statusline = {
        use_icons = vim.g.have_nerd_font,
    },
}

function M.cmp()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    local cmp_kinds = {
        Text = '  ',
        Method = '  ',
        Function = '  ',
        Constructor = '  ',
        Field = '  ',
        Variable = '  ',
        Class = '  ',
        Interface = '  ',
        Module = '  ',
        Property = '  ',
        Unit = '  ',
        Value = '  ',
        Enum = '  ',
        Keyword = '  ',
        Snippet = '  ',
        Color = '  ',
        File = '  ',
        Reference = '  ',
        Folder = '  ',
        EnumMember = '  ',
        Constant = '  ',
        Struct = '  ',
        Event = '  ',
        Operator = '  ',
        TypeParameter = '  ',
    }

    -- Customization for Pmenu
    vim.api.nvim_set_hl(0, 'PmenuSel', { bg = '#2A2A37', fg = 'NONE' })
    vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#FF9E3B', bg = '#1A1A22' })

    return {
        formatting = {
            format = function(_, vim_item)
                vim_item.kind = (cmp_kinds[vim_item.kind] or '') .. vim_item.kind
                return vim_item
            end,
        },
        view = {
            entries = 'custom',
        },
        snippet = {
            expand = function(args)
                -- luasnip.lsp_expand(args.body)
                vim.snippet.expand(args.body)
            end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        sources = {
            -- {
            --     name = 'lazydev',
            --     -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            --     group_index = 0,
            -- },
            { name = 'nvim_lsp' },
            -- { name = 'luasnip' },
            { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert {
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-y>'] = cmp.mapping.confirm { select = true },
            ['<C-Space>'] = cmp.mapping.complete {},
            ['<C-l>'] = cmp.mapping(function()
                if luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                end
            end, { 'i', 's' }),
            ['<C-h>'] = cmp.mapping(function()
                if luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                end
            end, { 'i', 's' }),
        },
    }
end

M.gitsigns = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = 'x' },
    topdelete = { text = 'X' },
    changedelete = { text = '~' },
}

M.which_key = {
    icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
            Up = '<Up> ',
            Down = '<Down> ',
            Left = '<Left> ',
            Right = '<Right> ',
            C = '<C-…> ',
            M = '<M-…> ',
            D = '<D-…> ',
            S = '<S-…> ',
            CR = '<CR> ',
            Esc = '<Esc> ',
            ScrollWheelDown = '<ScrollWheelDown> ',
            ScrollWheelUp = '<ScrollWheelUp> ',
            NL = '<NL> ',
            BS = '<BS> ',
            Space = '<Space> ',
            Tab = '<Tab> ',
            F1 = '<F1>',
            F2 = '<F2>',
            F3 = '<F3>',
            F4 = '<F4>',
            F5 = '<F5>',
            F6 = '<F6>',
            F7 = '<F7>',
            F8 = '<F8>',
            F9 = '<F9>',
            F10 = '<F10>',
            F11 = '<F11>',
            F12 = '<F12>',
        },
    },

    spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        -- { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    },
}

return M
