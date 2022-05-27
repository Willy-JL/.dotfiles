#!/bin/bash

set -e

# Install chaotic-aur
if [ ! -e /etc/pacman.d/chaotic-mirrorlist ] ; then
    echo "Installing chaotic-aur..."
    sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key FBA220DFC880C036
    sudo pacman -U \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo """
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
""" | sudo tee -a /etc/pacman.conf > /dev/null
fi

# Install packages in regular repos
echo "Installing standard packages..."
sudo pacman -Syu --needed $(comm -12 <(pacman -Slq | sort) <(sort pkglist.txt))

# Install paru
if ! which paru > /dev/null 2>&1 ; then
    echo "Installing paru..."
    sudo pacman -S --needed base-devel
    tmp="$(mktemp -d)"
    cwd="$PWD"
    git clone https://aur.archlinux.org/paru.git "$tmp"
    cd "$tmp"
    makepkg -si
    cd "$cwd"
fi

# Install packages from AUR
echo "Installing AUR packages..."
paru -Syu --needed $(comm -13 <(pacman -Slq | sort) <(sort pkglist.txt))

# Link dotfiles
echo "Linking dotfiles..."
mkdir -p                                          "$HOME"
ln -fs      "$PWD/home/you/.zshrc"                "$HOME/.zshrc"
mkdir -p                                          "$HOME/.config"
ln -fs      "$PWD/home/you/.config/starship.toml" "$HOME/.config/starship.toml"
mkdir -p                                          "/usr/local/bin"
sudo ln -fs "$PWD/usr/local/bin/pacman-R"         "/usr/local/bin/pacman-R"
sudo ln -fs "$PWD/usr/local/bin/videnc"           "/usr/local/bin/videnc"

# Change shell
if [ $SHELL != "/bin/zsh" ] ; then
    echo "Changing shell to zsh..."
    chsh -s /bin/zsh
fi

echo "Done!"
