local M = {}

if Nvim_cc_auto_read == nil then
    Nvim_cc_auto_read = false
end

if Nvim_cc_auto_sync == nil then
    Nvim_cc_auto_sync = false
end

if Nvim_cc_file_name == nil then
    Nvim_cc_file_name = "nvim-cc.txt"
end

function M.set_compile_command_from_file()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    if directory:sub(-4) == "/src" then
        directory = directory:sub(1, -5)
    end

    local file_path = directory .. "/" .. Nvim_cc_file_name
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
    if vim.bo.filetype == 'netrw' or vim.b.netrw_bufnr then
        return
    end
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local directory = vim.fn.fnamemodify(current_file, ":h")

    if directory:sub(-4) == "/src" then
        directory = directory:sub(1, -5)
    end

    vim.cmd('cd ' .. directory)
    print('cwd : ' .. directory)
end

if Nvim_cc_auto_read == true then
    local command = "autocmd BufEnter * lua require('nvim-cc').set_compile_command_from_file()"
    vim.cmd(command)
end

if Nvim_cc_auto_sync == true then
local command = "autocmd BufEnter * lua require('nvim-cc').sync_directory_to_buffer()"
vim.cmd(command)
end

return M
