return {
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    config = function()
      local jdtls = require 'jdtls'
      local jdtls_dap = require 'jdtls.dap'
      local jdtls_setup = require 'jdtls.setup'

      local home = os.getenv 'HOME'

      local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
      local root_dir = jdtls_setup.find_root(root_markers)

      local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
      local workspace_dir = home .. '/.cache/jdtls/workspace' .. project_name

      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

      local settings = {
        java = {
          jdt = {
            ls = {
              vmargs = '-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m',
            },
          },
          eclipse = {
            downloadSources = true,
          },
          configuration = {
            updateBuildConfiguration = 'interactive',
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
          references = {
            includeDecompiledSources = true,
          },
          format = {
            enabled = true,
            settings = {
              profile = 'GoogleStyle',
              url = home .. '/.config/lvim/.java-google-formatter.xml',
            },
          },
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        extendedClientCapabilities = extendedClientCapabilities,
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      }

      local config = {
        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-javaagent:/Users/mitlilc/.config/jdtls/plugins/lombok.jar',
          '-Xmx1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens',
          'java.base/java.util=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.lang=ALL-UNNAMED',

          '-jar',
          '/Users/mitlilc/.config/jdtls/plugins/org.eclipse.equinox.launcher_1.6.800.v20240330-1250.jar',
          '-configuration',
          '/Users/mitlilc/.config/jdtls/config_mac',
          '-data',
          '/Users/mitlilc/.config/jdtls/workspaces/' .. project_name,
        },

        capabilities = extendedClientCapabilities,

        on_init = function(client, _)
          client.notify('workspace/didChangeConfiguration', { settings = settings })
        end,

        flags = {
          allow_incremental_sync = true,
          server_side_fuzzy_completion = true,
        },

        on_attach = function(client, bufnr)
          jdtls.setup_dap {
            config_overrides = {},
            hotcodereplace = 'auto',
          }
          jdtls_dap.setup_dap_main_class_configs()

          -- Create a command `:Format` local to the LSP buffer
          vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })

          require('lsp_signature').on_attach({
            bind = true,
            padding = '',
            handler_opts = {
              border = 'rounded',
            },
            hint_prefix = '󱄑 ',
          }, bufnr)

          require('spring_boot').setup {}

          -- NOTE: comment out if you don't use Lspsaga
          require('lspsaga').setup {}
        end,
      }
      config.bundles = config.bundles or {}
      config.init_options = {
        bundles = config.bundles,
        extendedClientCapabilities = extendedClientCapabilities,
      }

      vim.list_extend(config.bundles, require('spring_boot').java_extensions() or {})

      require('jdtls').start_or_attach(config)
    end,
  },
  {
    'JavaHello/spring-boot.nvim',
    ft = 'java',
    dependencies = {
      'mfussenegger/nvim-jdtls', -- or nvim-java, nvim-lspconfig
      'ibhagwan/fzf-lua', -- optional
    },
  },
  {
    'nvimdev/lspsaga.nvim',
    config = function()
      print 'lsp is engaged'
      vim.keymap.set('n', '<leader><Tab>', ':Lspsaga code_action<CR>', { desc = 'Show code actions' })
      vim.keymap.set('n', '<leader><CR>', ':Lspsaga peek_definition<CR>', { desc = 'Show element definition' })
      require('lspsaga').setup {}
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons', -- optional
    },
  },
  {
    'ray-x/lsp_signature.nvim',
  },
}
