#!/usr/bin/env bash

set -e

blue='\e[1;34m'
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
white='\e[0;37m'

dotfiles_repo_dir=$(pwd)
backup_dir="$HOME/.dotfiles.orig"

# Dotfiles que se instalan en el home (~)
dotfiles_home_dir=(
    .zsh
    .aliases
    .bash_profile
    .bashrc
    .dircolors
    .editorconfig
    .exports
    .functions
    .gemrc
    .ripgreprc
    .wgetrc
    .zshrc
    .oh-my-zsh
)

# Dotfiles que se instalan en ~/.config
dotfiles_xdg_config_dir=(
    .alacritty
    .htop
    .tmux
)

# Paquetes requeridos para los dotfiles
required_packages=(
    zsh
    git
    curl
    wget
    vim
    tmux
    fonts-font-awesome
    fzf
    ripgrep
    bat
    exa
    fd
    findutils
    coreutils
    util-linux
    man
    man-pages
    tar
    gzip
    zip
    unzip
    htop
    build-essential
    libssl-dev
    libffi-dev
    python3
    python3-pip
    ruby
    ruby-dev
    gem
    composer
    nodejs
    npm
)

# Paquetes AUR (para Arch/Manjaro)
aur_packages=(
    alacritty
    ttf-font-awesome
    nerd-fonts-complete
    fzf
    ripgrep
    bat
    exa
    fd
    htop
)

# Print usage message
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [-option]

Options:
    --help          Print this message
    -i, --install   Install all config and dependencies
    -r, --restore   Restore old config
    -d, --deps      Only install dependencies (no dotfiles)
EOF
}

# Detectar el distribuidor de Linux
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/SuSE-release ]; then
        echo "suse"
    else
        echo "unknown"
    fi
}

# Instalar dependencias en Debian/Ubuntu
install_debian_deps() {
    echo -e "${blue}Installing dependencies for Debian/Ubuntu...${white}"

    # Actualizar repositorios
    sudo apt-get update -qq

    # Instalar paquetes base
    for pkg in "${required_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            echo -e "${yellow}Installing $pkg...${white}"
            sudo apt-get install -y -qq "$pkg" 2>/dev/null || true
        fi
    done

    # Instalar zsh si no está instalado
    if ! command -v zsh &> /dev/null; then
        echo -e "${yellow}Installing zsh...${white}"
        sudo apt-get install -y -qq zsh
    fi

    # Instalar Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${yellow}Installing Oh My Zsh...${white}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Instalar zsh plugins
    install_zsh_plugins
}

# Instalar dependencias en Arch/Manjaro
install_arch_deps() {
    echo -e "${blue}Installing dependencies for Arch/Manjaro...${white}"

    # Instalar yay si no está
    if ! command -v yay &> /dev/null && ! command -v trizen &> /dev/null; then
        echo -e "${yellow}Installing yay...${white}"
        cd /tmp
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg -si --noconfirm 2>/dev/null || true
        cd "$dotfiles_repo_dir"
    fi

    # Instalar paquetes base
    for pkg in "${required_packages[@]}"; do
        if ! pacman -Q "$pkg" &> /dev/null; then
            echo -e "${yellow}Installing $pkg...${white}"
            sudo pacman -S --noconfirm "$pkg" 2>/dev/null || true
        fi
    done

    # Instalar paquetes AUR
    for pkg in "${aur_packages[@]}"; do
        if ! pacman -Q "$pkg" &> /dev/null; then
            echo -e "${yellow}Installing AUR package: $pkg...${white}"
            yay -S --noconfirm "$pkg" 2>/dev/null || true
        fi
    done

    # Instalar zsh
    if ! command -v zsh &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    fi

    # Instalar Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    install_zsh_plugins
}

# Instalar dependencias en Fedora/RHEL
install_fedora_deps() {
    echo -e "${blue}Installing dependencies for Fedora/RHEL...${white}"

    # Instalar paquetes base
    for pkg in "${required_packages[@]}"; do
        if ! rpm -q "$pkg" &> /dev/null; then
            echo -e "${yellow}Installing $pkg...${white}"
            sudo dnf install -y -q "$pkg" 2>/dev/null || true
        fi
    done

    # Instalar zsh
    if ! command -v zsh &> /dev/null; then
        sudo dnf install -y -q zsh
    fi

    # Instalar Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    install_zsh_plugins
}

# Instalar plugins de zsh
install_zsh_plugins() {
    echo -e "${blue}Installing zsh plugins...${white}"

    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo -e "${yellow}Installing zsh-autosuggestions...${white}"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo -e "${yellow}Installing zsh-syntax-highlighting...${white}"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # zsh-completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        echo -e "${yellow}Installing zsh-completions...${white}"
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    fi

    # fzf tab completion
    if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
        echo -e "${yellow}Installing fzf-tab...${white}"
        git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
    fi
}

# Configurar zsh como shell por defecto
configure_zsh() {
    echo -e "${blue}Configuring zsh as default shell...${white}"

    # Verificar si zsh está instalado
    if ! command -v zsh &> /dev/null; then
        echo -e "${red}zsh is not installed. Please install zsh first.${white}"
        return 1
    fi

    # Obtener la ruta de zsh
    zsh_path=$(which zsh)

    # Verificar si zsh ya es el shell por defecto
    if [ "$SHELL" = "$zsh_path" ]; then
        echo -e "${green}zsh is already the default shell${white}"
    else
        # Añadir zsh a /etc/shells si no está
        if ! grep -q "^$zsh_path$" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
        fi

        # Cambiar shell por defecto
        if command -v chsh &> /dev/null; then
            sudo chsh -s "$zsh_path" "$USER" 2>/dev/null || \
            echo -e "${yellow}Could not change default shell automatically. Run: chsh -s $zsh_path${white}"
        else
            echo -e "${yellow}Could not change shell. Please run manually: chsh -s $zsh_path${white}"
        fi

        echo -e "${green}zsh configured as default shell${white}"
    fi

    # Crear enlace simbólico de .oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ] && [ -d "$dotfiles_repo_dir/.oh-my-zsh" ]; then
        ln -fs "$dotfiles_repo_dir/.oh-my-zsh" "$HOME/.oh-my-zsh"
    fi
}

# Instalar todos los dotfiles
install_dotfiles() {
    # Backup config
    if ! [ -f "$backup_dir/check-backup.txt" ]; then
        mkdir -p "$backup_dir/.config"
        cd "$backup_dir" || exit
        touch check-backup.txt

        # Backup to ~/.dotfiles.orig
        for dots_home in "${dotfiles_home_dir[@]}"; do
            env cp -rf "$HOME/${dots_home}" "$backup_dir" 2>/dev/null || true
        done

        # Backup some folder in ~/.config to ~/.dotfiles.orig/.config
        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]//./}"; do
            if [ -d "$HOME/.config/${dots_xdg_conf}" ]; then
                env cp -rf "$HOME/.config/${dots_xdg_conf}" "$backup_dir/.config" 2>/dev/null || true
            fi
        done

        # Backup again with Git
        if [ -x "$(command -v git)" ]; then
            git init &> /dev/null
            git add -u &> /dev/null
            git add . &> /dev/null
            git commit -m "Backup original config on $(date '+%Y-%m-%d %H:%M')" &> /dev/null
        fi

        # Output
        echo -e "${blue}Your config is backed up in ${backup_dir}\n" >&2
        echo -e "${red}Please do not delete check-backup.txt in .dotfiles.orig folder.${white}" >&2
        echo -e "It's used to backup and restore your old config.\n" >&2
    fi

    # Install dotfiles to home directory
    for dots_home in "${dotfiles_home_dir[@]}"; do
        if [ -e "$dotfiles_repo_dir/${dots_home}" ]; then
            env rm -rf "$HOME/${dots_home}"
            env ln -fs "$dotfiles_repo_dir/${dots_home}" "$HOME/"
        fi
    done

    # Install dotfiles to ~/.config
    mkdir -p "$HOME/.config"
    for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]}"; do
        if [ -e "$dotfiles_repo_dir/${dots_xdg_conf}" ]; then
            conf_name="${dots_xdg_conf//./}"
            env rm -rf "$HOME/.config/${conf_name}"
            env ln -fs "$dotfiles_repo_dir/${dots_xdg_conf}" "$HOME/.config/${conf_name}"
        fi
    done

    echo -e "${blue}New dotfiles are installed!\n${white}" >&2
    echo "There may be some errors when Terminal is restarted." >&2
    echo "Please read carefully the error messages and make sure all packages are installed." >&2
    echo -e "If you want to restore your old config, you can use ${red}./install.sh -r${white} command." >&2
}

# Desinstalar dotfiles
uninstall_dotfiles() {
    if [ -f "$backup_dir/check-backup.txt" ]; then
        for dots_home in "${dotfiles_home_dir[@]}"; do
            env rm -rf "$HOME/${dots_home}"
            env cp -rf "$backup_dir/${dots_home}" "$HOME/" 2>/dev/null || true
            env rm -rf "$backup_dir/${dots_home}"
        done

        for dots_xdg_conf in "${dotfiles_xdg_config_dir[@]//./}"; do
            env rm -rf "$HOME/.config/${dots_xdg_conf}"
            if [ -d "$backup_dir/.config/${dots_xdg_conf}" ]; then
                env cp -rf "$backup_dir/.config/${dots_xdg_conf}" "$HOME/.config" 2>/dev/null || true
            fi
            env rm -rf "$backup_dir/.config/${dots_xdg_conf}"
        done

        # Save old config in backup directory with Git
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

# Instalar solo dependencias
install_dependencies() {
    local distro
    distro=$(detect_distro)

    echo -e "${blue}Detected distribution: $distro${white}"

    case "$distro" in
        debian|ubuntu|linuxmint|pop)
            install_debian_deps
            ;;
        arch|manjaro|endeavouros)
            install_arch_deps
            ;;
        fedora|rhel|centos)
            install_fedora_deps
            ;;
        *)
            echo -e "${red}Unsupported distribution: $distro${white}"
            echo "Please install the following packages manually:"
            printf '%s\n' "${required_packages[@]}"
            return 1
            ;;
    esac

    echo -e "${green}Dependencies installed successfully!${white}"
}

main() {
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        -i|--install)
            echo -e "${blue}=== Installing dependencies first ===${white}"
            install_dependencies
            configure_zsh
            echo -e "${blue}=== Installing dotfiles ===${white}"
            install_dotfiles
            ;;
        -d|--deps)
            install_dependencies
            configure_zsh
            ;;
        -r|--restore)
            uninstall_dotfiles
            ;;
        *)
            echo "Command not found" >&2
            usage
            exit 1
            ;;
    esac
}

main "$@"