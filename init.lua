-- ~/.config/nvim/init.lua

function ColorMyPencils(color)
    color = color or "rose-pine-moon"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

-- Inicializa Lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/site/pack/packer/start/lazy.nvim")

-- Cargar el gestor de plugins
require('lazy').setup({
    -- Plugin para árboles de sintaxis (para resaltar y navegar)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- A list of parser names, or "all"
                ensure_installed = {
                    "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                    "jsdoc", "bash", "cpp",
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
                auto_install = true,

                indent = {
                    enable = true
                },

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "html" then
                            print("disabled")
                            return true
                        end

                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                "File larger than 100KB treesitter disabled for performance",
                                vim.log.levels.WARN,
                                { title = "Treesitter" }
                            )
                            return true
                        end
                    end,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = { "markdown" },
                },
            })

            local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            treesitter_parser_config.templ = {
                install_info = {
                    url = "https://github.com/vrischmann/tree-sitter-templ.git",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                },
            }

            vim.treesitter.language.register("templ", "templ")
        end

    },

    -- Plugin para búsqueda de archivos
    { 'nvim-telescope/telescope.nvim',    dependencies = { 'nvim-lua/plenary.nvim' } },

    -- Plugins para autocompletado y LSP
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'saadparwaiz1/cmp_luasnip', -- Para soporte de LuaSnip
        }
    },
    { 'neovim/nvim-lspconfig' },
    { 'L3MON4D3/LuaSnip' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- Plugins para herramientas adicionales
    { 'stevearc/conform.nvim' },             -- Conform para formateo
    { 'williamboman/mason.nvim' },           -- Mason para gestionar LSPs
    { 'williamboman/mason-lspconfig.nvim' }, -- Mason LSPconfig
    { 'j-hui/fidget.nvim' },                 -- Fidget para mostrar estado de LSP

    -- Tema
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({
                disable_background = true,
                styles = {
                    italic = false,
                },
            })
            ColorMyPencils();
        end
    },
    {
        "ThePrimeagen/harpoon",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            vim.keymap.set('n', '<leader>ha', ':lua require("harpoon.mark").add_file()<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<Leader>h', ':lua require("harpoon.ui").toggle_quick_menu()<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<Leader>1', ':lua require("harpoon.ui").nav_file(1)<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<Leader>2', ':lua require("harpoon.ui").nav_file(2)<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<Leader>3', ':lua require("harpoon.ui").nav_file(3)<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<Leader>4', ':lua require("harpoon.ui").nav_file(4)<CR>',
                { noremap = true, silent = true })
        end

    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup {
                options = {
                    theme = "horizon"
                }
            }
        end
    },
    {
        'terrortylor/nvim-comment',
        config = function()
            require('nvim_comment').setup({
                hook = function()
                    -- Si usas nvim-treesitter, puedes usar esto para actualizar los comentarios automáticamente
                    --require('ts_context_commentstring.internal').update_commentstring()
                end
            })
        end
    },
    {
        'mg979/vim-visual-multi',
        branch = 'master',
        config = function()
            -- Configuración opcional aquí
        end
    },
    {
        'rust-lang/rust.vim',
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end
    },
    {
        "simrat39/rust-tools.nvim",
        config = function()
            require("rust-tools").setup({})
        end
    },
    {
        'saecki/crates.nvim',
        ft = { "toml" },
        config = function()
            require("crates").setup {
                completion = {
                    cmp = {
                        enabled = true
                    },
                },
            }
            require('cmp').setup.buffer({
                sources = { { name = "crates" } }
            })
        end
    },
    {
        "aserowy/tmux.nvim",
        config = function()
            return require("tmux").setup(
                {
                    copy_sync = {
                        -- enables copy sync. by default, all registers are synchronized.
                        -- to control which registers are synced, see the `sync_*` options.
                        enable = true,

                        -- ignore specific tmux buffers e.g. buffer0 = true to ignore the
                        -- first buffer or named_buffer_name = true to ignore a named tmux
                        -- buffer with name named_buffer_name :)
                        ignore_buffers = { empty = false },

                        -- TMUX >= 3.2: all yanks (and deletes) will get redirected to system
                        -- clipboard by tmux
                        redirect_to_clipboard = false,

                        -- offset controls where register sync starts
                        -- e.g. offset 2 lets registers 0 and 1 untouched
                        register_offset = 0,

                        -- overwrites vim.g.clipboard to redirect * and + to the system
                        -- clipboard using tmux. If you sync your system clipboard without tmux,
                        -- disable this option!
                        sync_clipboard = true,

                        -- synchronizes registers *, +, unnamed, and 0 till 9 with tmux buffers.
                        sync_registers = true,

                        -- synchronizes registers when pressing p and P.
                        sync_registers_keymap_put = true,

                        -- synchronizes registers when pressing (C-r) and ".
                        sync_registers_keymap_reg = true,

                        -- syncs deletes with tmux clipboard as well, it is adviced to
                        -- do so. Nvim does not allow syncing registers 0 and 1 without
                        -- overwriting the unnamed register. Thus, ddp would not be possible.
                        sync_deletes = true,

                        -- syncs the unnamed register with the first buffer entry from tmux.
                        sync_unnamed = true,
                    },
                    navigation = {
                        -- cycles to opposite pane while navigating into the border
                        cycle_navigation = true,

                        -- enables default keybindings (C-hjkl) for normal mode
                        enable_default_keybindings = true,

                        -- prevents unzoom tmux when navigating beyond vim border
                        persist_zoom = false,
                    },
                    resize = {
                        -- enables default keybindings (A-hjkl) for normal mode
                        enable_default_keybindings = true,

                        -- sets resize steps for x axis
                        resize_step_x = 1,

                        -- sets resize steps for y axis
                        resize_step_y = 1,
                    }
                }
            )
        end
    },
})

-- Configuración de LSP y cmp
require("conform").setup({
    formatters_by_ft = {}
})

local cmp = require('cmp')
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    cmp_lsp.default_capabilities()
)

-- Configurar fidget
require("fidget").setup({})

-- Configurar mason
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls", "rust_analyzer", "gopls", "ts_ls"
    },
    handlers = {
        function(server_name) -- controlador predeterminado (opcional)
            require("lspconfig")[server_name].setup {
                capabilities = capabilities
            }
        end,

        -- Configuración especial para ZLS (Zig)
        zls = function()
            local lspconfig = require("lspconfig")
            lspconfig.zls.setup({
                root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                settings = {
                    zls = {
                        enable_inlay_hints = true,
                        enable_snippets = true,
                        warn_style = true,
                    },
                },
            })
            vim.g.zig_fmt_parse_errors = 0
            vim.g.zig_fmt_autosave = 0
        end,

        denols = function()
            local nvim_lsp = require('lspconfig')
            nvim_lsp.denols.setup {
                on_attach = on_attach,
                root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
            }

            nvim_lsp.ts_ls.setup {
                on_attach = on_attach,
                root_dir = nvim_lsp.util.root_pattern("package.json"),
                single_file_support = false
            }
        end,

        -- Configuración de lua_ls
        ["lua_ls"] = function()
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = "Lua 5.1" },
                        diagnostics = {
                            globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                        }
                    }
                }
            }
        end,

        -- Configuracion de jdtls
        ["jdtls"] = function()
            local lspconfig = require("lspconfig")

            -- Configuración básica para jdtls
            lspconfig.jdtls.setup({
                capabilities = capabilities, -- Asegúrate de definir o importar 'capabilities' previamente si es necesario
                settings = {
                    java = {
                        format = {
                            enabled = true, -- Habilitar formato automático
                        },
                        contentProvider = {
                            preferred = "fernflower", -- Establecer el descompilador preferido
                        },
                        build = {
                            autoBuild = true,   -- Deshabilitar la construcción automática del proyecto
                            autoRefresh = true, -- Evitar refrescar constantemente el proyecto
                        },
                        errors = {
                            enabled = true, -- Asegurar que los errores se linteren
                            -- validation = "interactive", -- Puede hacer que se validen solo cuando se le indica
                        },
                        signatureHelp = { enabled = true },
                        import = { enabled = true },
                        rename = { enabled = true },
                    },
                },
                init_options = {
                    bundles = {}, -- Aquí podrías agregar los "bundles" necesarios si tienes alguno
                },
                root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw", "pom.xml", "build.gradle" },
                    { upward = true })[1]),
                cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls" }, -- Asegúrate de tener la ruta correcta a jdtls
                on_attach = on_attach,                                  -- Aquí debes definir la función `on_attach` si no lo has hecho
            })
        end,
    }
})

local cmp_select = { behavior = cmp.SelectBehavior.Select }

-- Configuración de cmp
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- Para usuarios de `luasnip`
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- Para usuarios de luasnip
    }, {
        { name = 'buffer' },
    })
})

-- Configuración de diagnóstico
vim.diagnostic.config({
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

-- Cargar configuraciones adicionales
require('keymaps')    -- Configuración de keymaps
require('lsp')        -- Configuración de LSP
require('telescope')  -- Configuración de Telescope
require('settings')   -- Configuración general
require('colors')     -- Colores
require('treesitter') -- Configuración de Treesitter
