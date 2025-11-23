<div align="center">

# dotfiles

Personal dotfiles managed by [🪄 Wand](https://github.com/ochairo/wand)

![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat&logo=neovim&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=flat&logo=zsh&logoColor=white)

</div>

## Quick Start

### Prerequisites

- Install [Wand](https://github.com/ochairo/wand) package manager

  ```bash
  # Installation
  curl -sSL https://raw.githubusercontent.com/ochairo/wand/main/scripts/install.sh | bash
  ```

### Clone & Setup

- Clone this repository and configure dotfiles

  ```bash
  # Clone dotfiles repository to ~/.dotfiles
  git clone https://github.com/ochairo/dotfiles.git ~/.dotfiles
  ```

  ```bash
  # Navigate to the dotfiles directory
  cd ~/.dotfiles
  ```

  ```bash
  # Install all tools and create symlinks
  wand wandfile install
  ```

  This installs all formulas and creates symlinks as defined in the [wandfile](./wandfile.yaml).

<br>

<div align="center">

**Made with ❤︎ by [ochairo](https://github.com/ochairo)**

</div>
