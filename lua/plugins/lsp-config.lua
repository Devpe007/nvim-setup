return {
  'neovim/nvim-lspconfig',
  opts = {
    autoformat = true,
    -- make sure mason installs the server
    servers = {
      tsserver = {
        enabled = false,
      },
      prismals = {},
      eslint = {
        settings = {
          -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = 'auto' },
        },
      },
      tailwindcss = {
        -- exclude a filetype from the default_config
        filetypes_exclude = { 'markdown' },
        -- add additional filetypes to the default_config
        filetypes_include = {},
        -- to fully override the default_config, change the below
        -- filetypes = {}
      },
      yamlls = {
        -- Have to add this for yamlls to understand that we support line folding
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.yaml.schemas =
            vim.tbl_deep_extend('force', new_config.settings.yaml.schemas or {}, require('schemastore').yaml.schemas())
        end,
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = {
              enable = true,
            },
            validate = true,
            schemaStore = {
              -- Must disable built-in schemaStore support to use
              -- schemas from SchemaStore.nvim plugin
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = '',
            },
          },
        },
      },
      jsonls = {
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
        end,
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = { enable = true },
          },
        },
      },
      vtsls = {
        -- explicitly add default filetypes, so that we can extend
        -- them in related extras
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
        keys = {
          {
            'gD',
            function()
              local params = vim.lsp.util.make_position_params()
              LazyVim.lsp.execute({
                command = 'typescript.goToSourceDefinition',
                arguments = { params.textDocument.uri, params.position },
                open = true,
              })
            end,
            desc = 'Goto Source Definition',
          },
          {
            'gR',
            function()
              LazyVim.lsp.execute({
                command = 'typescript.findAllFileReferences',
                arguments = { vim.uri_from_bufnr(0) },
                open = true,
              })
            end,
            desc = 'File References',
          },
          {
            '<leader>co',
            LazyVim.lsp.action['source.organizeImports'],
            desc = 'Organize Imports',
          },
          {
            '<leader>cM',
            LazyVim.lsp.action['source.addMissingImports.ts'],
            desc = 'Add missing imports',
          },
          {
            '<leader>cu',
            LazyVim.lsp.action['source.removeUnused.ts'],
            desc = 'Remove unused imports',
          },
          {
            '<leader>cD',
            LazyVim.lsp.action['source.fixAll.ts'],
            desc = 'Fix all diagnostics',
          },
          {
            '<leader>cV',
            function()
              LazyVim.lsp.execute({ command = 'typescript.selectTypeScriptVersion' })
            end,
            desc = 'Select TS workspace version',
          },
        },
      },
    },
    setup = {
      tsserver = function()
        -- disable tsserver
        return true
      end,
      eslint = function()
        local function get_client(buf)
          return LazyVim.lsp.get_clients({ name = 'eslint', bufnr = buf })[1]
        end

        local formatter = LazyVim.lsp.formatter({
          name = 'eslint: lsp',
          primary = false,
          priority = 200,
          filter = 'eslint',
        })

        -- Use EslintFixAll on Neovim < 0.10.0
        if not pcall(require, 'vim.lsp._dynamic') then
          formatter.name = 'eslint: EslintFixAll'
          formatter.sources = function(buf)
            local client = get_client(buf)
            return client and { 'eslint' } or {}
          end
          formatter.format = function(buf)
            local client = get_client(buf)
            if client then
              local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
              if #diag > 0 then
                vim.cmd('EslintFixAll')
              end
            end
          end
        end

        -- register the formatter with LazyVim
        LazyVim.format.register(formatter)
      end,
      tailwindcss = function(_, opts)
        local tw = require('lspconfig.server_configurations.tailwindcss')
        opts.filetypes = opts.filetypes or {}

        -- Add default filetypes
        vim.list_extend(opts.filetypes, tw.default_config.filetypes)

        -- Remove excluded filetypes
        --- @param ft string
        opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
        end, opts.filetypes)

        -- Add additional filetypes
        vim.list_extend(opts.filetypes, opts.filetypes_include or {})
      end,
      yamlls = function()
        -- Neovim < 0.10 does not have dynamic registration for formatting
        if vim.fn.has('nvim-0.10') == 0 then
          LazyVim.lsp.on_attach(function(client, _)
            client.server_capabilities.documentFormattingProvider = true
          end, 'yamlls')
        end
      end,
      vtsls = function(_, opts)
        LazyVim.lsp.on_attach(function(client, buffer)
          client.commands['_typescript.moveToFileRefactoring'] = function(command, ctx)
            ---@type string, string, lsp.Range
            local action, uri, range = unpack(command.arguments)

            local function move(newf)
              client.request('workspace/executeCommand', {
                command = command.command,
                arguments = { action, uri, range, newf },
              })
            end

            local fname = vim.uri_to_fname(uri)
            client.request('workspace/executeCommand', {
              command = 'typescript.tsserverRequest',
              arguments = {
                'getMoveToRefactoringFileSuggestions',
                {
                  file = fname,
                  startLine = range.start.line + 1,
                  startOffset = range.start.character + 1,
                  endLine = range['end'].line + 1,
                  endOffset = range['end'].character + 1,
                },
              },
            }, function(_, result)
              ---@type string[]
              local files = result.body.files
              table.insert(files, 1, 'Enter new path...')
              vim.ui.select(files, {
                prompt = 'Select move destination:',
                format_item = function(f)
                  return vim.fn.fnamemodify(f, ':~:.')
                end,
              }, function(f)
                if f and f:find('^Enter new path') then
                  vim.ui.input({
                    prompt = 'Enter move destination:',
                    default = vim.fn.fnamemodify(fname, ':h') .. '/',
                    completion = 'file',
                  }, function(newf)
                    return newf and move(newf)
                  end)
                elseif f then
                  move(f)
                end
              end)
            end)
          end
        end, 'vtsls')
        -- copy typescript settings to javascript
        opts.settings.javascript =
          vim.tbl_deep_extend('force', {}, opts.settings.typescript, opts.settings.javascript or {})
      end,
    },
  },
}
