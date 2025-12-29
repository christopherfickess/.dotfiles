[TOC]
# .dotfiles
Bash Configuration Repo for Personal Use

##  Setup

To create this repo verify or make a file called `$HOME/.bashrc`

Clone the repo into your `$HOME/`

```bash
git clone https://github.com/christopherfickess/.dotfiles.git

# Will configure your bashrc to work
source $HOME/.dotfiles/setup.sh && setup_bashrc   
```

### Org Setup

To Configure Mattermost Org Bash Functions run the following commands

```bash
mkdir -p $HOME/.dotfiles/tmp

echo "export MATTERMOST=TRUE" >  $HOME/.dotfiles/tools/tmp/env.sh
# |
echo "export MATTERMOSTFED=TRUE" > $HOME/.dotfiles/tools/tmp/env.sh

# &&
echo "export USERNAME=\"ChrisFickess\"" > $HOME/.dotfiles/tools/tmp/env.sh
echo "export TELEPORT_LOGIN=\"<teleport.###.com>:443\"" > $HOME/.dotfiles/tools/tmp/env.sh
```

### AWS Setup 

Create file in `$HOME/.dotfiles/tools/tmp/users.sh` and then add all useful login function like the following 

```bash
function dev() {
  export env_tag="dev"
  export AWS_PROFILE="##"
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
}
```

### WSL Configuration Setup Procedures

To use wls use the following in gitbash terminal. This has been configured to install specific tools using the Distro of choice or by using the specific DISTRO=FedoraLinux-43. 

To use this the wsl function has been over written to do preconfigurations by simply running the wsl command. To pick a different Distro type 

- GitBash is a prereq for this

```bash
wsl <distro-name>
```

To setup wsl with fedora linux distro or your distro of choice you can run the following command

```bash
setup_wsl <DISTRO-NAME> 
# or
setup_wsl 
```

Without a value you will get fedora linux 43 version

You will need to exit then run post install script to configure tools. This is built into the setup_wsl function but you must exit the wsl terminal and rerun the command to finalize the install process


```bash
setup_wsl 
```

### Tool useful Install List

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
- [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)

### Repos to install

- [.dotfiles](https://github.com/christopherfickess/.dotfiles)
- [Mattermost](https://github.com/mattermost/mattermost)
- [Mattermost-Cloud](https://github.com/mattermost/mattermost-cloud)
- [Mattermost-Cloud-Monitoring](https://github.com/mattermost/mattermost-cloud-monitoring)
- [Mattermost-operator](https://github.com/mattermost/mattermost-operator)
- [Mattermost-IaC](https://github.com/mattermost/delivery-iac)

Then open a new admin terminal and run the `windows_first_time_setup` function. This will install all relavent tools and WSL config with Fedora and all SRE Libs needed. Additionally, this will sync the Bash configuration between windows and WSL Linux subsystems.