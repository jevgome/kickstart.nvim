return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  -- ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    'BufReadPre '
      .. vim.fn.expand '~'
      .. '/Github/Obsidian-Vault/*.md',
    'BufNewFile ' .. vim.fn.expand '~' .. '/Github/Obsidian-Vault/*.md',
  },

  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = {
      {
        name = 'Main',
        path = vim.fn.expand '~' .. '/Github/Obsidian-Vault/',
      },
    },

    notes_subdir = 'notes',
    -- see below for full list of options 👇

    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
      create_new = true,
    },

    callbacks = {
      enter_note = function(_, note)
        vim.keymap.set('n', '<C-b>', '<cmd>Obsidian backlinks<cr>', {
          buffer = note.bufnr,
          desc = 'Open backlinks',
        })
      end,
    },

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'.
      -- You may have as many periods in the note ID as you'd like—the ".md" will be added automatically
      local prefix = ''
      local suffix = tostring(os.date('%m', os.time()))
        .. '-'
        .. tostring(os.date('%d', os.time()))
        .. '-'
        .. tostring(os.date('%Y', os.time()))
        .. '_'
        .. tostring(os.date('%H', os.time()))
        .. '-'
        .. tostring(os.date('%S', os.time()))
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        prefix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          prefix = prefix .. string.char(math.random(65, 90))
        end
      end
      return prefix .. '-' .. suffix
    end,

    -- Optional, customize how note file names are generated given the ID, target directory, and title.
    ---@param spec { id: string, dir: obsidian.Path, title: string|? }
    ---@return string|obsidian.Path The full path to the new note.
    note_path_func = function(spec)
      -- This is equivalent to the default behavior.
      local path = spec.dir / tostring(spec.id)
      return path:with_suffix '.md'
    end,

    -- Optional, customize how wiki links are formatted. You can set this to one of:
    -- _ "use_alias_only", e.g. '[[Foo Bar]]'
    -- _ "prepend*note_id", e.g. '[[foo-bar|Foo Bar]]'
    -- * "prepend*note_path", e.g. '[[foo-bar.md|Foo Bar]]'
    -- * "use_path_only", e.g. '[[foo-bar.md]]'
    -- Or you can set it to a function that takes a table of options and returns a string, like this:
    -- Optional, customize how markdown links are formatted.

    wiki_link_func = function(opts)
      return require('obsidian.util').wiki_link_id_prefix(opts)
    end,

    markdown_link_func = function(opts)
      return require('obsidian.util').markdown_link(opts)
    end,

    -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
    -- way then set 'mappings = {}'.
    legacy_commands = false,
    footer = {
      enabled = true, -- turn it off
      -- separator = "", -- insert a blank line
      format = '{{backlinks}} backlinks  {{properties}} properties  {{words}} words  {{chars}} chars', -- works like the template system
      -- format = "({{backlinks}} backlinks)", -- limit to backlinks
      hl_group = '@property', -- Use another hl group
    },

    new_notes_location = 'notes_subdir',

    -- Optional, configure additional syntax highlighting / extmarks.
    -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
    ui = {
      enable = true, -- set to false to disable all additional syntax features
      update_debounce = 200, -- update delay after a text change (in milliseconds)
      max_file_length = 5000, -- disable UI features for files with more than this many lines
      -- Use bullet marks for non-checkbox lists.
      bullets = { char = '•', hl_group = 'ObsidianBullet' },
      external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
      -- Replace the above with this if you don't have a patched font:
      -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      reference_text = { hl_group = 'ObsidianRefText' },
      highlight_text = { hl_group = 'ObsidianHighlightText' },
      tags = { hl_group = 'ObsidianTag' },
      block_ids = { hl_group = 'ObsidianBlockID' },
      hl_groups = {
        -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
        ObsidianTodo = { bold = true, fg = '#f78c6c' },
        ObsidianDone = { bold = true, fg = '#89ddff' },
        ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
        ObsidianTilde = { bold = true, fg = '#ff5370' },
        ObsidianImportant = { bold = true, fg = '#d73128' },
        ObsidianBullet = { bold = true, fg = '#89ddff' },
        ObsidianRefText = { underline = true, fg = '#c792ea' },
        ObsidianExtLinkIcon = { fg = '#c792ea' },
        ObsidianTag = { italic = true, fg = '#89ddff' },
        ObsidianBlockID = { italic = true, fg = '#89ddff' },
        ObsidianHighlightText = { bg = '#75662e' },
      },
    },

    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
      name = 'telescope.nvim',
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      note_mappings = {
        -- Create a new note from your query.
        new = '<C-x>',
        -- Insert a link to the selected note.
        insert_link = '<C-l>',
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = '<C-x>',
        -- Insert a tag at the current location.
        insert_tag = '<C-l>',
      },
    },
  },
}
