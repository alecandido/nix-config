local parent = ...

require(parent .. ".setup")
local opts = require(parent .. ".opts")

require("lazy").setup(parent .. ".plugins", opts)
