#!/bin/bash -eu

if ! brew list --cask | grep -q "visual-studio-code"; then
  brew install --cask visual-studio-code
fi

# -------------------- Essentials ----------------------------------------------
code --install-extension aaron-bond.better-comments            # Comment Highlighter
code --install-extension chrmarti.regex                        # Regex Previewer
code --install-extension streetsidesoftware.code-spell-checker # Spell Checker
code --install-extension usernamehw.errorlens                  # Error Displayer
code --install-extension wmaurer.change-case                   # Change Case

# -------------------- Formatter -----------------------------------------------
code --install-extension esbenp.prettier-vscode
code --install-extension EditorConfig.EditorConfig
code --install-extension foxundermoon.shell-format

# -------------------- Nvim ----------------------------------------------------
code --install-extension asvetliakov.vscode-neovim

# -------------------- Copilot -------------------------------------------------
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat

# -------------------- Git -----------------------------------------------------
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph

# -------------------- API Test ------------------------------------------------
# code --install-extension Arjun.swagger-viewer
# code --install-extension rangav.vscode-thunder-client

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
