# fl🎈at👟ner.nvim
**Your keymap is your command**


![floatrunner-demo](https://github.com/user-attachments/assets/72a0aabd-5a55-48d5-89ee-7f0d3bd04c78)


## What is floatrunner.nvim?
```floatrunner.nvim``` is a Neovim plugin for running:
- build scripts (build.sh, Makefile, CMake, etc)
- compiler commands (gcc, g++, rustc, javac, etc)
- your programs (./anything)

inside a floating terminal inside Neovim.

## Why floatrunner.nvim?
```floatrunner.nvim``` reduces my typical workflow:
- Make changes to a file
- ~~Quit Neovim~~
- ~~Run command(s)~~ **Hit three keys**
- ~~Open Neovim~~

While there definitely are [other options](#similar-projects) for the same use case, I decided to build everything from scratch, to configure all to my liking, and (hopefully) learn more about Neovim.

## 🗝 Requirements

- **Neovim v0.11+**

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

## 🕹️ Usage
Try these commands to see if installation went successfull:
```
:FloatRunner toggle
:FloatRunner run
:FloatRunner build
```
**Note**: the two latter commands are expected to result in a warning if no configuration is provided.

Run ```:help floatrunner``` to see more information on usage.

## ⚙️ Configuration

There is no default configuration provided in ```floatrunner.nvim```. Feel free to configure everything to your liking: keymaps, languages supported, and build scripts scenarios. Those are configured using ```maps```, ```langs```, and ```builds``` lua tables respectively. Here's an example configuration:

```lua
require("floatrunner").setup({
  maps = {
    floaterm_on = "<leader>tt",
    floaterm_off = "<esc><esc>",
  },

  langs = {
    {
      exts = { "c" },
      command = "gcc %s -o %s && ./%s",
      argv = { "%.", "%", "%" }
    }
  },

  builds = {
    ["Makefile"] = "make"
  }
})
```
### Maps
Here's the full list of the available actions for mapping:
- ```floaterm_on``` shows the floating terminal
- ```floaterm_off``` hides the floating terminal (works in ```terminal``` mode)
- ```floatrun``` runs the current file
- ```floatbuild``` builds the project

**Note**: for ```floatbuild``` to work the current file has to be present in any directory of the project (not necessarily the one containing the build file).

### Langs
As shown in the example config, ```floatrunner.nvim``` expects you to use ```%``` to indicate the name of the current file with no extension (use ```%.``` for current file **with** extension) in ```langs.argv```.

**Note**: although ```gcc``` command uses the same argument twice, ```floatrunner.nvim``` expects as many arguments in ```argv``` as there are ```%s``` placeholders in ```command``` string.

### Builds
Each build scenario is expected to be a key-value pair, consisting of the name of the build file (including extension), and the command to run respectively.

## Credits
### Similar projects
- [FTerm.nvim](https://github.com/numToStr/FTerm.nvim) by numToStr
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) by akinsho
- [Compiler.nvim](https://github.com/Zeioth/compiler.nvim) by Zeioth
- [Code_Runner](https://github.com/CRAG666/code_runner.nvim) by CRAG666

### Special thanks
- TJ DeVries for [Advent of Neovim](https://youtube.com/playlist?list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM&feature=shared) series that inspired this project

## TODO
- ~~Fix terminal creation on Linux~~
- ~~Make build files findable from directories that contain the project~~
- Add window creation configuration
- Refactor LuaCATS docs
- ~~Change getbuildcmd() behavior to look until ~ instead of /~~
- ~~Reconsider .gitignore~~
- Refactor tests
- Add debugging commands
- Define highlight groups
