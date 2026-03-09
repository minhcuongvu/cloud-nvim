return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<F5>",      function() require("dap").continue() end,          desc = "Debug: Start/Continue" },
      { "<F10>",     function() require("dap").step_over() end,         desc = "Debug: Step Over" },
      { "<F11>",     function() require("dap").step_into() end,         desc = "Debug: Step Into" },
      { "<F12>",     function() require("dap").step_out() end,          desc = "Debug: Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end,        desc = "Debug: Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end,         desc = "Debug: Run Last" },
      { "<leader>dt", function() require("dapui").toggle() end,         desc = "Debug: Toggle UI" },
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")
      local is_win = vim.fn.has("win32") == 1
      local ext    = is_win and ".exe" or ""
      local mason  = vim.fn.stdpath("data") .. "/mason/packages"

      dapui.setup()

      -- Auto open/close UI on debug session start/end
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      -- Helper: normalize path separators for Windows
      local function normpath(p)
        if is_win then return p:gsub("/", "\\") end
        return p
      end

      -----------------------------------------------------------------------
      -- C# (.NET Core / .NET 5+) via netcoredbg
      -----------------------------------------------------------------------
      dap.adapters.coreclr = {
        type = "executable",
        command = mason .. "/netcoredbg/netcoredbg/netcoredbg" .. ext,
        args = { "--interpreter=vscode" },
        options = { exit_codes = { 0, 1 } },
      }

      local cs_configs = {
        {
          type = "coreclr",
          name = "Launch",
          request = "launch",
          cwd = function() return normpath(vim.fn.getcwd()) end,
          program = function()
            local cwd = vim.fn.getcwd()
            -- Search bin/Debug/<tfm>/ directories (e.g. net8.0, net9.0)
            local tfm_dirs = vim.fn.glob(cwd .. "/bin/Debug/net*/", true, true)
            for _, dir in ipairs(tfm_dirs) do
              local dll = vim.fn.glob(dir .. "*.dll")
              if dll ~= "" then
                local files = vim.split(dll, "\n")
                local project = vim.fn.fnamemodify(cwd, ":t")
                for _, f in ipairs(files) do
                  if vim.fn.fnamemodify(f, ":t") == project .. ".dll" then
                    return normpath(f)
                  end
                end
              end
            end
            -- Fallback: check bin/Debug/ directly
            for _, fext in ipairs({ "exe", "dll" }) do
              local glob = vim.fn.glob(cwd .. "/bin/Debug/*." .. fext)
              if glob ~= "" then
                local files = vim.split(glob, "\n")
                if #files == 1 then return normpath(files[1]) end
              end
            end
            return vim.fn.input("Path to dll/exe: ", cwd .. "/bin/Debug/", "file")
          end,
          stopAtEntry = false,
        },
        {
          type = "coreclr",
          name = "MCD Proxy (Development)",
          request = "launch",
          cwd = normpath("C:/Dev/CISS/MyCommunityDirectory/MyCommunityDirectory.Proxy"),
          program = normpath("C:/Dev/CISS/MyCommunityDirectory/MyCommunityDirectory.Proxy/bin/Debug/net8.0/MyCommunityDirectory.Proxy.dll"),
          args = {
            "--environment", "Development",
            "--urls", "https://www.mcd.com:5443;http://localhost:5000",
          },
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
          },
          stopAtEntry = false,
          justMyCode = false,
        },
        {
          type = "coreclr",
          name = "Attach",
          request = "attach",
          processId = function() return require("dap.utils").pick_process() end,
        },
      }
      dap.configurations.cs     = cs_configs
      dap.configurations.csharp = cs_configs

      -----------------------------------------------------------------------
      -- C / C++ / Rust via codelldb
      -----------------------------------------------------------------------
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = mason .. "/codelldb/extension/adapter/codelldb" .. ext,
          args = { "--port", "${port}" },
        },
      }

      local cpp_configs = {
        {
          type = "codelldb",
          name = "Launch",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            local search = is_win
              and { "/build/Debug/*.exe", "/build/*.exe", "/build/Release/*.exe", "/out/build/Debug/*.exe" }
              or  { "/build/*", "/build/Debug/*", "/build/Release/*" }
            for _, pattern in ipairs(search) do
              local glob = vim.fn.glob(cwd .. pattern)
              if glob ~= "" then
                local files = vim.split(glob, "\n")
                -- On Linux, filter to executable files only
                if not is_win then
                  files = vim.tbl_filter(function(f)
                    return vim.fn.executable(f) == 1 and vim.fn.isdirectory(f) == 0
                  end, files)
                end
                if #files == 1 then return files[1] end
              end
            end
            return vim.fn.input("Path to executable: ", cwd .. "/build/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          type = "codelldb",
          name = "Attach",
          request = "attach",
          pid = function() return require("dap.utils").pick_process() end,
        },
      }
      dap.configurations.c   = cpp_configs
      dap.configurations.cpp = cpp_configs

      -----------------------------------------------------------------------
      -- Go via delve (dlv)
      -----------------------------------------------------------------------
      dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = mason .. "/delve/dlv" .. ext,
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }

      local go_configs = {
        {
          type = "delve",
          name = "Launch file",
          request = "launch",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Launch package",
          request = "launch",
          program = "${workspaceFolder}",
        },
        {
          type = "delve",
          name = "Launch test",
          request = "launch",
          mode = "test",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Attach",
          request = "attach",
          mode = "local",
          processId = function() return require("dap.utils").pick_process() end,
        },
      }
      dap.configurations.go = go_configs
    end,
  },
}
