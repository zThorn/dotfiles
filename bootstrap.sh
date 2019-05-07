#!/bin/bash
distro=$(lsb_release -id -s)

if [[ $distro == *"Ubuntu"* ]]; then
    pkgmgr="sudo apt-get install -y "
    distro="ubuntu"
fi

if [ $distro == "ubuntu" ] then
    $pkgmgr software-properties-common
    
    #Add neovim Repository
    sudo add-apt-repository ppa:neovim-ppa/stable

    #Add docker-ce repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    #Add docker-ce gpg key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    #Add google source for gsutil
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    #Add google gpg key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -\n
    sudo apt-get update
fi

echo "Installing for env: $ubuntu"
#Install zsh, neovim
$pkgmgr zsh
$pkgmgr neovim
$pkgmgr python3,python3-pip,python3-venv
$pkgmgr 'gcc-c++'
$pkgmgr golang
$pkgmgr sshfs
$pkgmgr pass
$pkgmgr google-cloud-sdk
 
echo "if test -t 1; then
     exec zsh
 fi" >> ~/.bashrc

echo "Installing Oh-My-Zsh"
#Install Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#Source bashrc, switch to zsh
source ~/.bashrc

echo "Getting ZSHRC"
#Get ZSHRC & source
wget https://raw.githubusercontent.com/zThorn/dotfiles/master/.zshrc -O ~/.zshrc
source ~/.zshrc


echo "Installing GPG deps"
$pkgmgr gnupg2 pcscd scdaemon
gpg2 --list-keys

#TODO -- Add .gnupg/gpg.conf & gpg-agent.conf to dotfiles 
#Use SHA2 instead of SHA1
echo "personal-digest-preferences SHA256" >> ~/.gnupg/gpg.conf
echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >> ~/.gnupg/gpg.conf

#Set a default keyserver
echo "keyserver hkp://keys.gnupg.net" >> ~/.gnupg/gpg.conf

#Configure gpg-agent:
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf

#Restart agent
gpg-connect-agent killagent /bye
gpg-connect-agent /bye

#Add to ~/.bashrc (or other place that gets run automatically).
echo "export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh" >> ~/.zshrc

#Use gpg2 instead of gpg.
echo "alias gpg=gpg2" >> ~/.zshrc


#Configure git, I'm expecting to already have my yubikey plugged in, otherwise the signingkey
#won't be found
git config --global user.email "contact@zachthornton.dev"
git config --global user.name "Zach Thornton"
git config --global commit.gpgsign true
git config --global user.signingkey FB1D591455003C56


