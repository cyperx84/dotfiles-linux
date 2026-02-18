return {
  "ghostty",
  dir = vim.fn.has('mac') == 1
    and '/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/'
    or '/usr/share/nvim/site/',
  lazy = false
}
