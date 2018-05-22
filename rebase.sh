#!/bin/bash

cd ~
rm -rvf MasterNodes
sudo apt install -y dialog && git clone https://github.com/celsoluism/MasterNodes.git && cd MasterNodes && chmod -R +x * && clear && ./install.sh
