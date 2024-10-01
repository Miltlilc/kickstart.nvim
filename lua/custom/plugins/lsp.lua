return {
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    config = function()
      local jdtls = require 'jdtls'
      -- local jdtls_dap = require 'jdtls.dap'
      local jdtls_setup = require 'jdtls.setup'

      local home = os.getenv 'HOME'

      local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
      local root_dir = jdtls_setup.find_root(root_markers)

      local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')

      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
      local settings = {
        java = {
          contentProvider = { preferred = 'fernflower' },
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
              url = home .. '/.config/nvim/.java-google-formatter.xml',
            },
          },
        },
        signatureHelp = { enabled = true },
        extendedClientCapabilities = extendedClientCapabilities,
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      }

      local config = {
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-javaagent:/Users/v.kochanov/.config/jdtls/plugins/lombok.jar',
          '-Xmx1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens',
          'java.base/java.util=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.lang=ALL-UNNAMED',

          '-jar',
          '/Users/v.kochanov/.config/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',
          '-configuration',
          '/Users/v.kochanov/.config/jdtls/config_mac_arm',
          '-data',
          '/Users/v.kochanov/.config/jdtls/workspaces/' .. project_name,
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
          -- jdtls.setup_dap {
          --   config_overrides = {},
          --   hotcodereplace = 'auto',
          -- }
          -- jdtls_dap.setup_dap_main_class_configs()

          require('lsp_signature').on_attach({
            bind = true,
            padding = '',
            handler_opts = {
              border = 'rounded',
            },
            hint_prefix = '󱄑 ',
          }, bufnr)

          require('spring_boot').setup {}

          -- -- NOTE: comment out if you don't use Lspsaga
          -- require('lspsaga').setup {}
        end,
      }
      config.bundles = {}
      vim.list_extend(config.bundles, require('spring_boot').java_extensions() or {})
      vim.list_extend(config.bundles, vim.split(vim.fn.glob(home .. '/.config/jdtls/decomp/server/*.jar'), '\n'))

      config.init_options = {
        bundles = config.bundles,
        extendedClientCapabilities = extendedClientCapabilities,
      }

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
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require 'null-ls'
      null_ls.setup {
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
    end,
  },
  'nvim-treesitter/nvim-treesitter', -- optional
  'nvim-tree/nvim-web-devicons', -- optional
  'ray-x/lsp_signature.nvim',
}
