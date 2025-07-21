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

## 🕹️ Usage
Try these commands to see if installation went successfull:
```
:FloatRunner toggle
:FloatRunner run
:FloatRunner build
```
**Note**: the two latter commands are expected to result in a warning printed to you screen due to lack of configuration.

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

## Contributing
Contributions are highly appreciated!
