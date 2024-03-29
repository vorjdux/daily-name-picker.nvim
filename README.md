
# DailyNamePicker.nvim

An interactive Neovim plugin for managing and selecting names from a daily list. Features include loading names from input or files, picking random names, and unpicking names. Enhance your daily workflow with ease and flexibility.

## Installation

**Using Vim-Plug**

```vim
Plug 'vorjdux/DailyNamePicker.nvim'
```

**Using Packer**

```lua
use {'vorjdux/DailyNamePicker.nvim'}
```

## Usage

After installation, you can use the following commands within Neovim:

- `:DailyLoadNames` - Load names from a comma-separated string.
- `:DailyLoadNamesFromFile` - Load names from a file.
- `:DailyPickRandomName` - Pick a random name from the list.
- `:DailyDisplayNames` - Display the names in a full-screen overlay.
- `:DailyUnpickLastName` - Unpick the last picked name, making it available again.
- `:DailyClosePopup` - Close the names display popup.

### Example

Load names and pick a random name:

```vim
:DailyLoadNames John,Doe,Jane,Doe
:DailyPickRandomName
```

## Features

- **Load Names**: Load names from a comma-separated string or a file.
- **Pick Random Name**: Randomly select a name from the list.
- **Unpick Name**: Make the last picked name available for picking again.
- **Display Names**: Show all names in a full-screen overlay with special highlighting for picked and used names.

## Configuration

You can bind the commands to specific keys in your `init.vim` or `init.lua` for quicker access. For example:

```lua
vim.api.nvim_set_keymap('n', '<leader>dn', ':DailyLoadNames<CR>', {noremap = true, silent = true})
```

## Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Commit your changes with a clear description.
4. Push your branch and open a pull request.

### Issues

Feel free to submit issues for bugs, enhancements, or feature requests.

## License

[GNU General Public License v2.0](LICENSE) - feel free to use and contribute to the development of `DailyNamePicker.nvim`.
