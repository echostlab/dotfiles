<h1 align="center">dotfiles ❤ ~/</h1>

<p align="center">
    <b>Screenshots</b><br>
    <a href="https://dikiaap.pages.dev/img/dotfiles/zsh.png">Zsh</a>&nbsp;&nbsp;&nbsp;
    <a href="https://dikiaap.pages.dev/img/dotfiles/tmux.png">tmux</a>&nbsp;&nbsp;&nbsp;
    <a href="https://dikiaap.pages.dev/img/dotfiles/colors.png">Colors</a>&nbsp;&nbsp;&nbsp;
    <a href="https://dikiaap.pages.dev/img/dotfiles/dircolors.png">dircolors</a>
</p>


## Details

- CLI
    - [Zsh](https://github.com/zsh-users/zsh) - A shell designed for interactive use, although it is also a powerful scripting language.
        - [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) - An open source, community-driven framework for managing your Zsh configuration.
        - [z](https://github.com/rupa/z) - Tracks your most used directories, based on frecency.
    - [Bash](https://cgit.git.savannah.gnu.org/cgit/bash.git) - A Unix shell and command language.
    - [tmux](https://github.com/tmux/tmux) - A terminal multiplexer.
        - [tmux-better-mouse-mode](https://github.com/NHDaly/tmux-better-mouse-mode) - A tmux plugin to better manage the mouse.
        - [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - A tmux plugin that enhances tmux search.
    - [Neovim](https://github.com/neovim/neovim) - Hyperextensible Vim-based text editor.
        - [Minimalist](https://github.com/dikiaap/minimalist) - A Material Color Scheme Darker for Vim and inspired by Material Theme.
        - [vim-airline](https://github.com/vim-airline/vim-airline) - Lean and mean status/tabline for Vim that's light as air.
        - [More config](https://github.com/dikiaap/dotfiles/blob/master/init.vim).
    - [Git](https://github.com/git/git) - A free and open source distributed version control system.
        - [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) - Make your diffs human readable instead of machine readable.
    - [htop](https://github.com/htop-dev/htop) - An interactive process viewer.
    - [bat](https://github.com/sharkdp/bat) - A cat clone with syntax highlighting and Git integration.
    - [fzf](https://github.com/junegunn/fzf) - A command-line fuzzy finder.
    - [ripgrep](https://github.com/BurntSushi/ripgrep) - A line-oriented search tool that recursively searches directories for a regex pattern.
    - [Wget](https://cgit.git.savannah.gnu.org/cgit/wget.git) - A free software package for retrieving files using HTTP, HTTPS, FTP, and FTPS.
    - [Hack](https://github.com/source-foundry/Hack) - Terminal font.
- Terminal
    - [Alacritty](https://github.com/alacritty/alacritty) - A cross-platform, GPU-accelerated terminal emulator.


## Installation

Run the installer with automatic dependency installation:

```bash
./install.sh -i
```

This will:
1. Install all required dependencies (zsh, tmux, neovim, fzf, ripgrep, etc.)
2. Configure zsh as your default shell
3. Install Oh My Zsh if not present
4. Link all terminal and plugin dotfiles

### Options

- `-i` - Install all config (with dependencies)
- `-d` - Install dependencies only
- `-r` - Restore old config


## Requirements

- Linux/macOS
- zsh
- curl, wget, git
- tmux
- neovim
- fzf
- ripgrep
- htop
- bat


## License

[MIT](LICENSE)