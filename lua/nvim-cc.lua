local M = {}

local auto_read = false
local auto_sync = false

function M.auto_read(input)
    auto_read = input
end

function M.auto_sync(input)
    auto_sync = input
end

function M.set_compile_command_from_file()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    if directory:sub(-4) == "/src" then
        directory = directory:sub(1, -5)
    end

    local file_path = directory .. "/nvim-cc.txt"
    local success, file_content = pcall(vim.fn.readfile, file_path)

    if success and #file_content > 0 then
        GLOBAL_compile_command = file_content[1]
        print("nvim-cc : ".. GLOBAL_compile_command)
    end
end

function M.input_compile_command()
    if GLOBAL_compile_command == nil then
        GLOBAL_compile_command = ""
    end
    local compile_command = vim.fn.input("Enter Compile command : ", GLOBAL_compile_command)
    if compile_command ~= "" then
        GLOBAL_compile_command = compile_command
    end
end

function M.run_compile_command()
    if GLOBAL_compile_command == "" or GLOBAL_compile_command == nil then
        print("There is no compile command specified!")
        return
    end
    local cmd = "split | terminal echo \"> " .. GLOBAL_compile_command .. "\" && " .. GLOBAL_compile_command
    vim.cmd(cmd)
    vim.cmd("startinsert")
end

function M.run_compile_command_silent()
    if GLOBAL_compile_command == "" or GLOBAL_compile_command == nil then
        print("There is no compile command specified!")
        return
    end
    local cmd = ":!"..GLOBAL_compile_command
    vim.cmd(cmd)
end

function M.sync_directory_to_buffer()
        local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    if directory:sub(-4) == "/src" then
        directory = directory:sub(1, -5)
    end

    vim.cmd('cd ' .. directory)
    print('cwd : ' .. directory)
end

if auto_read == true then
    vim.api.nvim_exec([[
    autocmd BufEnter * lua require('nvim-cc').set_compile_command_from_file()
    ]], false)
end

if auto_sync == true then
    vim.api.nvim_exec([[
    autocmd BufEnter * lua require('nvim-cc').sync_directory_to_buffer()
    ]], false)
end

return M
