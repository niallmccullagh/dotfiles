#!/bin/bash

failed_items=""

function install_package() {
echo EXECUTING: brew install $1 $2
    brew install $1 $2
    [ $? -ne 0 ] && $failed_items="$failed_items $1"  # package failed to install.
}

function install_cask_package() {
    echo EXECUTING: brew cask install $1
    brew cask install $1
    [ $? -ne 0 ] && $failed_items="$failed_items $1"  # package failed to install.
}

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

brew tap caskroom/cask
brew tap caskroom/fonts
brew tap caskroom/versions
brew tap homebrew/dupes
brew tap homebrew/versions

# ack: Search tool like grep, but optimized for programmers
install_package ack ''

# awscli: Official Amazon AWS command-line interface
#install_package awscli ''

# bash: Bash 4 (Bourne-again SHell) is a UNIX command interpreter
# Noteon’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
install_package bash ''

#homebrew/versions/bash-completion2:
install_package bash-completion2 ''

# caskroom/cask/brew-cask: [no description]
install_package brew-cask ''

# cheat: Create and view interactive cheat sheets for *nix commands
install_package cheat ''

# dnsmasq: Lightweight DNS forwarder and DHCP server
install_package dnsmasq ''

# docker: Pack, ship and run any application as a lightweight container
install_package docker ''

# docker-compose: Isolated development environments using Docker
install_package docker-compose ''

# docker-machine: Create Docker hosts locally and on cloud providers
install_package docker-machine ''

# findutils: Collection of GNU find, xargs, and locate
install_package findutils ''

# fleetctl: Distributed init system
install_package fleetctl ''

# freetype: Software library to render fonts
install_package freetype ''

# git: Distributed revision control system
install_package git ''

# gnu-sed: GNU implementation of the famous stream editor
install_package gnu-sed '  --with-default-names'

# gnu-tar: GNU version of the tar archiving utility
install_package gnu-tar ''

# go: Go programming environment
install_package go ''

# gradle: Build system based on the Groovy language
install_package gradle ''

# homebrew/dupes/grep: [no description]
install_package grep '  --with-default-names'

# groovy: Groovy: a Java-based scripting language
install_package groovy ''

# jenv: Manage your Java environment
install_package jenv ''

# jmeter: Load testing and performance measurement application
#install_package jmeter '  --with-plugins'

# jq: Lightweight and flexible command-line JSON processor
install_package jq ''

# logstalgia: Web server access log visualizer
#install_package logstalgia ''

# macvim: GUI for vim, made for OS X
install_package macvim ''

# markdown: Text-to-HTML conversion tool
install_package markdown ''

# maven: Java-based project management
install_package maven ''

# ngrepetwork grep
install_package ngrep ''

# homebrew/dupes/openssh: OpenBSD freely-licensed SSH connectivity tools
install_package homebrew/dupes/openssh ''

# openssl: OpenSSL SSL/TLS cryptography library
install_package openssl ''

# p7zip: 7-Zip (high compression file archiver) implementation
install_package p7zip ''

# postgresql: Object-relational database system
#install_package postgresql ''

# python3: Interpreted, interactive, object-oriented programming language
install_package python3 ''

# rabbitmq: Messaging broker
#install_package rabbitmq ''

# ruby: Powerful, clean, object-oriented scripting language
install_package ruby ''

# ssh-copy-id: Add a public key to a remote machine's authorized_keys file
install_package ssh-copy-id ''

# tomcat: Implementation of Java Servlet and JavaServer Pages
#install_package tomcat ''

# tree: Display directories as trees (with optional color/HTML output)
install_package tree ''

# vim: Vi "workalike" with many additional features
install_package vim '  --override-system-vi'

# wget: Internet file retriever
install_package wget ''

########################################################################
# Casks
########################################################################
install_cask_package 1password
install_cask_package alfred
install_cask_package bartender
#install_cask_package clamxav
install_cask_package cleanmymac
install_cask_package colloquy
install_cask_package fantastical
install_cask_package firefox
install_cask_package font-inconsolata
install_cask_package google-chrome
install_cask_package intellij-idea
install_cask_package iterm2
install_cask_package java
install_cask_package knock
install_cask_package macdown
install_cask_package skype
install_cask_package slack
install_cask_package sonos
install_cask_package spectacle
install_cask_package spotify
install_cask_package tunnelbear
install_cask_package virtualbox

########################################################################
# Set bash v4 up
########################################################################
if [ $(cat /private/etc/shells | grep '$(brew --prefix)/bin/bash' | wc -l) -eq 0 ]; then
    sudo bash -c 'echo $(brew --prefix)/bin/bash >> /private/etc/shells'
fi

# Change the shell for the user
chsh -s $(brew --prefix)/bin/bash

########################################################################
# Finish up
########################################################################
[ ! -z $failed_items ] && echo The following items were failed to install: && echo $failed_items

# Remove outdated versions from the cellar.
brew cleanup
