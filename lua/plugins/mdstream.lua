-- ~/.config/nvim/lua/plugins/mdstream.lua
return {
  name = "mdstream",
  dir = vim.fn.stdpath("config"),
  ft = "markdown",

  init = function()
    vim.keymap.set("n", "<leader>mr", function()
      -- Interpreted languages: can run from stdin
      local stdin_runners = {
        bash = { "bash" },
        sh = { "sh" },
        python = { "python3" },
        lua = { "lua" },
        javascript = { "node" },
        js = { "node" },
      }

      -- Compiled languages: need temp file, compile, then run
      local compiled_runners = {
        go = {
          ext = ".go",
          compile = function(file) return { "go", "run", file } end,
        },
        c = {
          ext = ".c",
          compile = function(file)
            local out = file:gsub("%.c$", "")
            return { "sh", "-c", string.format("gcc -o %s %s && %s; rm -f %s", out, file, out, out) }
          end,
        },
        cpp = {
          ext = ".cpp",
          compile = function(file)
            local out = file:gsub("%.cpp$", "")
            return { "sh", "-c", string.format("g++ -std=c++17 -o %s %s && %s; rm -f %s", out, file, out, out) }
          end,
        },
        ["c++"] = {
          ext = ".cpp",
          compile = function(file)
            local out = file:gsub("%.cpp$", "")
            return { "sh", "-c", string.format("g++ -std=c++17 -o %s %s && %s; rm -f %s", out, file, out, out) }
          end,
        },
        rust = {
          ext = ".rs",
          compile = function(file)
            local out = file:gsub("%.rs$", "")
            return { "sh", "-c", string.format("rustc -o %s %s && %s; rm -f %s", out, file, out, out) }
          end,
        },
        rs = {
          ext = ".rs",
          compile = function(file)
            local out = file:gsub("%.rs$", "")
            return { "sh", "-c", string.format("rustc -o %s %s && %s; rm -f %s", out, file, out, out) }
          end,
        },
      }

      local buf = vim.api.nvim_get_current_buf()
      local row = vim.api.nvim_win_get_cursor(0)[1] - 1
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

      -- =========================
      -- find opening fence
      -- =========================
      local start_row
      for i = row, 0, -1 do
        if lines[i + 1]:match("^```") then
          start_row = i
          break
        end
      end
      if not start_row then
        vim.notify("No code fence found", vim.log.levels.ERROR)
        return
      end

      -- =========================
      -- find closing fence
      -- =========================
      local end_row
      for i = start_row + 1, #lines - 1 do
        if lines[i + 1]:match("^```") then
          end_row = i
          break
        end
      end
      if not end_row then
        vim.notify("Unclosed code fence", vim.log.levels.ERROR)
        return
      end

      -- =========================
      -- language + runner
      -- =========================
      local lang = lines[start_row + 1]:match("^```(%S+)")
      local stdin_cmd = stdin_runners[lang]
      local compiled = compiled_runners[lang]
      if not stdin_cmd and not compiled then
        vim.notify("Unsupported language: " .. tostring(lang), vim.log.levels.ERROR)
        return
      end

      -- =========================
      -- remove existing result
      -- =========================
      local after = end_row + 1
      if lines[after + 1] == "" and lines[after + 2] == "```text" then
        local r_end
        for i = after + 2, #lines - 1 do
          if lines[i + 1] == "```" then
            r_end = i
            break
          end
        end
        if r_end then
          vim.api.nvim_buf_set_lines(buf, after, r_end + 1, false, {})
          lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        end
      end

      -- =========================
      -- extract code
      -- =========================
      local code = table.concat(vim.api.nvim_buf_get_lines(buf, start_row + 1, end_row, false), "\n")

      -- =========================
      -- insert fresh result fence
      -- =========================
      local insert_at = end_row + 1
      vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, {
        "",
        "```text",
        "```",
      })

      local write_row = insert_at + 2

      -- =========================
      -- async execution
      -- =========================
      local function run_with_output(cmd, stdin_data, temp_file)
        vim.system(cmd, {
          stdin = stdin_data,

          stdout = function(_, data)
            if not data then
              return
            end
            vim.schedule(function()
              local out = vim.split(data, "\n", { trimempty = true })
              vim.api.nvim_buf_set_lines(buf, write_row, write_row, false, out)
              write_row = write_row + #out
            end)
          end,

          stderr = function(_, data)
            if not data then
              return
            end
            vim.schedule(function()
              local out = vim.split(data, "\n", { trimempty = true })
              vim.api.nvim_buf_set_lines(buf, write_row, write_row, false, out)
              write_row = write_row + #out
            end)
          end,
        }, function()
          -- Cleanup temp file after execution
          if temp_file then
            vim.schedule(function()
              os.remove(temp_file)
            end)
          end
        end)
      end

      if stdin_cmd then
        -- Interpreted language: pass code via stdin
        run_with_output(stdin_cmd, code, nil)
      else
        -- Compiled language: write to temp file, compile and run
        local temp_file = os.tmpname() .. compiled.ext
        local f = io.open(temp_file, "w")
        if not f then
          vim.notify("Failed to create temp file", vim.log.levels.ERROR)
          return
        end
        f:write(code)
        f:close()

        local compile_cmd = compiled.compile(temp_file)
        run_with_output(compile_cmd, nil, temp_file)
      end
    end, { desc = "Markdown: async run code block (override result)" })
  end,
}
