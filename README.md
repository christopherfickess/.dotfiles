# .dotfiles
Bash Configuration Repo for Personal Use

# Starting

To create this repo verify or make a file called `$HOME/.bashrc`

Clone the repo into your `$HOME/`

```bash
git clone https://github.com/christopherfickess/.dotfiles.git

code $HOME/.bashrc
```

add the following lines to the dotfiles

```bash
if [ -f "$HOME/.dotfiles/.bashrc" ]; then  source "$HOME/.dotfiles/.bashrc"; fi
```

Then open a new terminal
