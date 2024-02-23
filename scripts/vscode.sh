#!/bin/zsh -eu

echo "vscode.sh"

brew install --cask visual-studio-code

# -------------------- Essentials ----------------------------------------------
code --install-extension aaron-bond.better-comments            # Comment Highlighter
code --install-extension streetsidesoftware.code-spell-checker # Spell Checker
code --install-extension usernamehw.errorlens                  # Error Displayer
code --install-extension chrmarti.regex                        # Regex Previewer
code --install-extension wmaurer.change-case                   # Change Case

# -------------------- Formatter -----------------------------------------------
code --install-extension esbenp.prettier-vscode

# -------------------- Nvim ----------------------------------------------------
code --install-extension asvetliakov.vscode-neovim

# -------------------- Copilot -------------------------------------------------
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat

# -------------------- Git -----------------------------------------------------
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph

# -------------------- Live Share ----------------------------------------------
code --install-extension ms-vsliveshare.vsliveshare

# -------------------- API Test ------------------------------------------------
code --install-extension Arjun.swagger-viewer
code --install-extension rangav.vscode-thunder-client

# -------------------- HTML ----------------------------------------------------
code --install-extension formulahendry.auto-close-tag

# -------------------- CSS -----------------------------------------------------
code --install-extension anseki.vscode-color

# -------------------- JavaScript ----------------------------------------------
code --install-extension dbaeumer.vscode-eslint

# -------------------- Markdown ------------------------------------------------
code --install-extension DavidAnson.vscode-markdownlint

# -------------------- MySQL ---------------------------------------------------
code --install-extension Oracle.mysql-shell-for-vs-code

# -------------------- Draw.io -------------------------------------------------
code --install-extension hediet.vscode-drawio

# -------------------- Theme ---------------------------------------------------
code --install-extension Catppuccin.catppuccin-vsc

exit 0