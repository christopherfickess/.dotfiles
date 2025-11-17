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


To use wls use the following in gitbash terminal 

```
wsl ---install 


Install List

- Python 3.14
- Kubernetes 
- AWS CLI
- GitBash
- Docker
- Go
- TailScale (VPN)
- VS Code
- Perl
- Perplexity
- Mattermost
- (Need to Do) Mattermost CLI

Repos to install

- [.dotfiles](https://github.com/christopherfickess/.dotfiles)
- [Mattermost](https://github.com/mattermost/mattermost)
- [Mattermost-Cloud](https://github.com/mattermost/mattermost-cloud)
- [Mattermost-Cloud-Monitoring](https://github.com/mattermost/mattermost-cloud-monitoring)
- [Mattermost-operator](https://github.com/mattermost/mattermost-operator)
- [Mattermost-IaC](https://github.com/mattermost/delivery-iac)

Then open a new admin terminal and run the `windows_first_time_setup` function. This will install all relavent tools and WSL config with Fedora and all SRE Libs needed. Additionally, this will sync the Bash configuration between windows and WSL Linux subsystems.