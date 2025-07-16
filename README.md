# fl🎈at👟ner.nvim
Your keymap is ~~my~~ **your** command

## What is Floatrunner?
```floatrunner.nvim``` is a Neovim plugin for running:
- build scripts (build.sh, Makefile, CMake, etc)
- compiler commands (gcc, g++, rustc, javac, etc)
- your programs (./**anything**)

inside a floating terminal **inside** Neovim.

## Why Floatrunner?
```floatrunner.nvim``` reduces my typical workflow:
- Make changes to a file
- ~~Quit Neovim~~
- ~~Run command(s) (or spam ⬆️)~~ **Hit three keys**
- See the errors, and question even trying to become a SWE
- ~~Open Neovim~~

While there definitely were other options for the same use case, I decided to build everything from scratch, to configure all to my liking, and (hopefully) learn more about Neovim.

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "rQxwX3/floatrunner.nvim",
  config = function()
    require("floatrunner").setup()
  end
}
```

## Contributing
Contributions are highly appreciated!
