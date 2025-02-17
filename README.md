# WIP
# About
My NixOS configuration.

# Features

## Philosophy
I have used several linux distributions in the past, however NixOS stands out because of the Nix package manager. Being able to create a parametrized linux distribution using a simple programming language is far too much power to be left unused. My configuration sadly only scratches the surface of what is possible.

I want my work environment to feel snappy, be reproducible and surprise free. All of these are compile time guarentees when you use Rust and as such, most common linux utilities - even as simple as `ls` or `cp` or `rm`, have been oxidized.

## Features
### Desktop Environment
The configuration uses GNOME 47 with heavy GNOME Shell modifications. It is not the fastest or the snappiest desktop environment, however it is looks great and is hassle free.

### Terminal Emulator

### Text Editor

# Options

# Deployments
I use my configurations on the following devices.

## Desktop (WSL)
A desktop computer with
- AMD Ryzen 5 3600 (6 cores, 3.60 GHz)
- 32GB DDR4 3200MHz Memory
- NVIDIA GeForce RTX 2070 Super
- M.2 SSD (3000MB/s R&W)  

Using [WSL2](https://learn.microsoft.com/en-us/windows/wsl/about) and [NixOS-WSL](https://github.com/nix-community/NixOS-WSL).

## Laptop
[Lenovo IdeaPad Slim 5i 13th Gen](https://store.lenovo.com/in/en/ideapad-slim-5i-13th-gen-35-56cms-intel-i7-cloud-grey-82xd0040in-372-1.html), with
- Intel i7-13620H (6 P-cores at 4.90 GHz, 4 E-cores at 3.60 GHz)
- 16GB LPDDR5 5200MHz Memory
- Integrated Intel UHD Graphics
- M.2 SSD (6000MB/s R&W)
