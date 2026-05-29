#!/usr/bin/env bash

set -e

blue='\e[1;34m'
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
white='\e[0;37m'
dotfiles_repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
backup_dir="$HOME/.dotfiles.orig"

# Terminal and plugin dotfiles only (no desktop/i3 stuff)
dotfiles_home_dir=(.zsh .aliases .bash_profile .bashrc .dircolors .editorconfig .exports
                   .functions .gemrc .ripgreprc .wgetrc .zshrc)
dotfiles_xdg_config_dir=(.alacritty .htop .tmux)

# Required packages for terminal and plugins
required_packages=(
    # Zsh and Oh My Zsh
    zsh
    curl
    wget
    git

    # Terminal utilities
    tmux
    htop
    bat
    fzf
    ripgrep
    neovim
    git
    wget

    # Fonts
    fonts-hack
    fonts-font-awesome

    # Optional but recommended
    composer
    ruby
)

# Print usage message.
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [-option]

Options:
    --help    Print this message
    -i        Install all config (with dependencies)
    -d        Install dependencies only
    -r        Restore old config
EOF
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v yum &> /dev/null; then
        echo "yum"
    else
        echo "unknown"
    fi
}

# Install dependencies based on package manager
install_dependencies() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)

    echo -e "${blue}Detecting package manager: ${green}${pkg_manager}${white}\n"

    case "$pkg_manager" in
        apt)
            echo -e "${blue}Updating package lists...${white}"
            sudo apt-get update -qq

            echo -e "${blue}Installing required packages...${white}"
            sudo apt-get install -y -qq "${required_packages[@]}" 2>/dev/null || {
                # Try installing individually if group install fails
                for pkg in "${required_packages[@]}"; do
                    sudo apt-get install -y -qq "$pkg" 2>/dev/null || true
                done
            }
            ;;
        dnf|yum)
            echo -e "${blue}Installing required packages...${white}"
            sudo "$pkg_manager" install -y "${required_packages[@]}" 2>/dev/null || {
                for pkg in "${required_packages[@]}"; do
                    sudo "$pkg_manager" install -y "$pkg" 2>/dev/null || true
                done
            }
            ;;
        pacman)
            echo -e "${blue}Installing required packages...${white}"
            sudo pacman -Sy --noconfirm "${required_packages[@]}" 2>/dev/null || {
                for pkg in "${required_packages[@]}"; do
                    sudo pacman -Sy --noconfirm "$pkg" 2>/dev/null || true
                done
            }
            ;;
        brew)
            echo -e "${blue}Installing required packages...${white}"
            brew install "${required_packages[@]}"
            ;;
        *)
            echo -e "${yellow}Warning: Could not detect package manager.${white}"
            echo "Please install the following packages manually:"
            printf '  - %s\n' "${required_packages[@]}"
            ;;
    esac

    echo -e "${green}Dependencies installed successfully!${white}\n"
}

# Configure zsh as default shell
configure_zsh() {
    echo -e "${blue}Configuring Zsh as default shell...${white}"

    # Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        echo -e "${red}Error: zsh is not installed. Please install zsh first.${white}"
        return 1
    fi

    # Get zsh path
    local zsh_path
    zsh_path=$(command -v zsh)

    # Check if zsh is already the default shell
    if [ "$SHELL" = "$zsh_path" ]; then
        echo -e "${green}Zsh is already your default shell.${white}"
    else
        # Try to add zsh to available shells
        if [ -f /etc/shells ]; then
            if ! grep -q "^$zsh_path$" /etc/shells; then
                echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
            fi
        fi

        # Try to change default shell
        if command -v chsh &> /dev/null; then
            if sudo -n chsh -s "$zsh_path" 2>/dev/null; then
                echo -e "${green}Zsh set as default shell!${white}"
            else
                echo -e "${yellow}Could not change default shell automatically.${white}"
                echo "Run the following command to set zsh as default:"
                echo "  chsh -s $zsh_path"
            fi
        else
            echo -e "${yellow}Could not change default shell automatically.${white}"
            echo "Run the following command to set zsh as default:"
            echo "  chsh -s $zsh_path"
        fi
    fi

    # Install Oh My Zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${blue}Installing Oh My Zsh...${white}"
        export RUNZSH=no
        export CHSH=no
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${green}Oh My Zsh installed!${white}"
    else
        echo -e "${green}Oh My Zsh is already installed.${white}"
    fi

    echo -e "${green}Zsh configuration complete!${white}\n"
}

install_dotfiles() {
    # Backup config.
    if ! [ -f "$backup_dir/check-backup.txt" ]; then
        mkdir -p "$backup_dir/.config"
        cd "$backup_dir" || exit
        touch check-backup.txt

        # Backup to ~/.dotfiles.orig
        for dots_home in "${dotfiles_home_dir[@]}"
        do
            if [ -e "$HOME/${dots_home}" ]; then
                env cp -rf "$HOME/${dots_home}" "$backup_dir" 2>/dev/null || true
            fi
        done

        # Backup some folder in ~/.config to ~/.dotfiles.orig/.config
        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
        do
            local xdg_name="${dots_xdg_conf#.}"
            if [ -e "$HOME/.config/${xdg_name}" ]; then
                env cp -rf "$HOME/.config/${xdg_name}" "$backup_dir/.config" 2>/dev/null || true
            fi
        done

        # Backup again with Git.
        if [ -x "$(command -v git)" ]; then
            git init &> /dev/null
            git add -u &> /dev/null
            git add . &> /dev/null
            git commit -m "Backup original config on $(date '+%Y-%m-%d %H:%M')" &> /dev/null
        fi

        # Output.
        echo -e "${blue}Your config is backed up in ${backup_dir}\n" >&2
        echo -e "${red}Please do not delete check-backup.txt in .dotfiles.orig folder.${white}" >&2
        echo -e "It's used to backup and restore your old config.\n" >&2
    fi

    # Install config.
    for dots_home in "${dotfiles_home_dir[@]}"
    do
        if [ -e "$dotfiles_repo_dir/${dots_home}" ]; then
            env rm -rf "$HOME/${dots_home}"
            env ln -fs "$dotfiles_repo_dir/${dots_home}" "$HOME/"
        fi
    done

    # Install config to ~/.config.
    mkdir -p "$HOME/.config"
    for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
    do
        local xdg_name="${dots_xdg_conf#.}"
        if [ -e "$dotfiles_repo_dir/${dots_xdg_conf}" ]; then
            env rm -rf "$HOME/.config/${xdg_name}"
            env ln -fs "$dotfiles_repo_dir/${dots_xdg_conf}" "$HOME/.config/${xdg_name}"
        fi
    done

    echo -e "${blue}New dotfiles is installed!\n${white}" >&2
    echo "There may be some errors when Terminal is restarted." >&2
    echo "Please read carefully the error messages and make sure all packages are installed. See more info in README.md." >&2
    echo "Note that the author of this dotfiles uses dev branch in some packages." >&2
    echo -e "If you want to restore your old config, you can use ${red}./install.sh -r${white} command." >&2
}

uninstall_dotfiles() {
    if [ -f "$backup_dir/check-backup.txt" ]; then
        for dots_home in "${dotfiles_home_dir[@]}"
        do
            if [ -e "$backup_dir/${dots_home}" ]; then
                env rm -rf "$HOME/${dots_home}"
                env cp -rf "$backup_dir/${dots_home}" "$HOME/" 2>/dev/null || true
                env rm -rf "$backup_dir/${dots_home}"
            fi
        done

        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"
        do
            local xdg_name="${dots_xdg_conf#.}"
            if [ -e "$backup_dir/.config/${xdg_name}" ]; then
                env rm -rf "$HOME/.config/${xdg_name}"
                env cp -rf "$backup_dir/.config/${xdg_name}" "$HOME/.config" 2>/dev/null || true
                env rm -rf "$backup_dir/.config/${xdg_name}"
            fi
        done

        # Save old config in backup directory with Git.
        if [ -x "$(command -v git)" ]; then
            cd "$backup_dir" || exit
            git add -u &> /dev/null
            git add . &> /dev/null
            git commit -m "Restore original config on $(date '+%Y-%m-%d %H:%M')" &> /dev/null
        fi
    fi

    if ! [ -f "$backup_dir/check-backup.txt" ]; then
        echo -e "${red}You have not installed this dotfiles yet.${white}" >&2
        exit 1
    else
        echo -e "${blue}Your old config has been restored!\n${white}" >&2
        echo "Thanks for using my dotfiles." >&2
        echo "Enjoy your next journey!" >&2
    fi

    env rm -rf "$backup_dir/check-backup.txt"
}

main() {
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        -i)
            install_dependencies
            configure_zsh
            install_dotfiles
            ;;
        -d)
            install_dependencies
            ;;
        -r)
            uninstall_dotfiles
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"