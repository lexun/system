#!/usr/bin/env bash

nix run home-manager -- switch -b backup --flake .
