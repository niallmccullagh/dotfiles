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

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

brew tap caskroom/cask
brew tap caskroom/fonts
brew tap caskroom/versions
brew tap niallmccullagh/taps

# Heptio AWS Authenticator: K8S authentication using AWS creds
install_package heptio-authenticator-aws ''

# Terraform: Tool to build, change, and version infrastructure
install_package terraform ''

# Terraform landscape: Easier diff of terraform changes
install_package terraform_landscape ''

# SOPS: encryption of yaml files using AWS KMS
install_package sops ''

# kubernetes PS1: Kubernetes command-line prompt
install_package kube-ps1 ''

# kubernetes cli: Kubernetes command-line interface
install_package kubectl ''

# kops: Production Grade K8s Installation, Upgrades, and Management
install_package kops ''

# kubernetes-helm: Package installer for kubernetes
install_package kubernetes-helm ''

# assume-role: Easy way to assume an AWS role
install_package assume-role ''

# yarn: Yet another package manager for javascript
install_package yarn ''

# GNU awk utility
install_package gawk ''

# watch: Executes a program periodically, showing output fullscreen
install_package watch ''

# Packer: Tool for creating identical machine images for multiple platforms
install_package packer ''

# ack: Search tool like grep, but optimized for programmers
install_package ack ''

# awscli: Official Amazon AWS command-line interface
install_package awscli ''

# bash: Bash 4 (Bourne-again SHell) is a UNIX command interpreter
# Noteon’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
install_package bash ''

#homebrew/versions/bash-completion2:
install_package bash-completion2 ''

#bash-git-prompt: Informative, fancy bash prompt for Git users
install_package bash-git-prompt ''

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

# findutils: Collection of GNU find, xargs, and locate
install_package findutils ''

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

# jq: Lightweight and flexible command-line JSON processor
install_package jq ''

# macvim: GUI for vim, made for OS X
install_package macvim ''

# markdown: Text-to-HTML conversion tool
install_package markdown ''

# maven: Java-based project management
install_package maven ''

# ngrepetwork grep
install_package ngrep ''

# nodenv: Manage multiple NodeJS versions
install_package nodenv ''

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

# rbenv: Ruby version manager
install_package rbenv ''

# ruby-build: Install various Ruby versions and implementations
install_package ruby-build ''

# ssh-copy-id: Add a public key to a remote machine's authorized_keys file
install_package ssh-copy-id ''

# tree: Display directories as trees (with optional color/HTML output)
install_package tree ''

# vim: Vi "workalike" with many additional features
install_package vim '  --override-system-vi'

# wget: Internet file retriever
install_package wget ''

# bat: Clone of cat(1) with syntax highlighting and Git integration
install_package bat ''

# fzf: Command-line fuzzy finder written in Go
install_package fzf ''

# adr-tools: CLI tool for working with Architecture Decision Records
install_package adr-tools ''

# shellcheck: Static analysis and lint tool, for (ba)sh scripts
install_package shellcheck ''

# watchman: Watch files and take action when they change
install_package watchman ''

########################################################################
# Casks
########################################################################
#install_cask_package 1password
install_cask_package alfred
install_cask_package atom
install_cask_package bartender
install_cask_package beyond-compare
install_cask_package caffeine
install_cask_package datagrip
install_cask_package docker
install_cask_package drawio
install_cask_package fantastical
install_cask_package firefox
install_cask_package font-inconsolata
install_cask_package google-chrome
install_cask_package google-chrome-canary
install_cask_package gimp
install_cask_package intellij-idea
install_cask_package iterm2
install_cask_package google-chat
install_cask_package java
install_cask_package knock
install_cask_package little-snitch
install_cask_package macdown
install_cask_package postman 
install_cask_package skype
install_cask_package slack
install_cask_package spectacle
install_cask_package spotify
install_cask_package visual-studio-code
install_cask_package webstorm
install_cask_pacakge wireshark

########################################################################
# Set bash v4 up
########################################################################
# Switch to using brew-installed bash as default shell
if ! fgrep -q "$(brew --prefix)/bin/bash" /etc/shells; then
    echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells;
    chsh -s $(brew --prefix)/bin/bash;
fi;

########################################################################
# Finish up
########################################################################
[ ! -z $failed_items ] && echo The following items were failed to install: && echo $failed_items

# Remove outdated versions from the cellar.
brew cleanup
