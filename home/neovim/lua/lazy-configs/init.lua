local parent = ...

require(parent .. ".setup")
require(parent .. ".opts")

require("lazy").setup(parent .. ".plugins", opts)
