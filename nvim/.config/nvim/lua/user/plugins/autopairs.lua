return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      disable_filetype = { "TelescopePrompt", "lisp", "scheme" },
      disable_in_visualblock = true,
      fast_wrap = {}, -- <A-e> to use fast wrap
    },
    config = function(_, npairs_opts)
      local npairs = require("nvim-autopairs")
      local rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")
      npairs.setup(npairs_opts)

      local function add_in_pair_for_pair(a1, ins, a2, lang)
        npairs.add_rule(rule(ins, ins, lang)
          :with_pair(function(opts)
            return a1 .. a2 == opts.line:sub(opts.col - #a1, opts.col + #a2 - 1)
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            return a1 .. ins .. ins .. a2 == opts.line:sub(col - #a1 - #ins + 1, col + #ins + #a2) -- insert only works for #ins == 1 anyway
          end))
      end
      add_in_pair_for_pair("(", " ", ")")
      add_in_pair_for_pair("{", " ", "}")
      add_in_pair_for_pair("[", " ", "]")
      -- add_in_pair_for_pair("(", "*", ")", "ocaml")
      -- add_in_pair_for_pair("(*", " ", "*)", "ocaml")

      -- move past punctuation
      for _, punct in pairs({ ",", ";" }) do
        npairs.add_rules({
          rule("", punct)
            :with_move(function(opts)
              return opts.char == punct
            end)
            :with_pair(function()
              return false
            end)
            :with_del(function()
              return false
            end)
            :with_cr(function()
              return false
            end)
            :use_key(punct),
        })
      end
    end,
  },
  -- { "gpanders/nvim-parinfer", ft = { "lisp", "scheme" } }, -- purpose built autopairing for lisp family of languages
}
