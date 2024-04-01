# Ensure Nix is installed
if ! command -v nix &>/dev/null; then
	echo "Nix is required to use this command but it is not installed."
	read -p "Would you like to install it now? (y/N) " yn
	case $yn in
	[Yy]*)
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
		exit 0
		;;
	*)
		echo "Please install Nix and try again."
		echo "https://github.com/DeterminateSystems/nix-installer"
		exit 1
		;;
	esac
fi

# Ensure direnv is installed and active
if ! command -v direnv &>/dev/null; then
	echo "Direnv is required to use this command but it is not installed."
	read -p "Would you like to install it now? (y/N) " yn
	case $yn in
	[Yy]*)
		nix profile install nixpkgs#direnv
		echo "Direnv installed."
		echo $'\e[33m'Please follow the instructions on https://direnv.net/docs/hook.html to set up the shell hook.$'\e[0m'
		exit 0
		;;
	*)
		echo "Please install direnv and try again."
		echo "  run 'nix profile install nixpkgs#direnv'"
		echo "  then follow instructions on https://direnv.net/docs/hook.html to set up the shell hook."
		exit 1
		;;
	esac
elif [[ -z "${REPO}" ]]; then
	echo "It seems you're not in a direnv shell."
	echo "Please run 'direnv allow' to activate it."
	exit 1
fi

# Activate devenv shell if not yet active
if [[ -z "${DEVENV_ROOT}" ]]; then
	if [[ "$1" != "shell" ]] && [[ "$1" != "configure" ]]; then
		echo $'\e[35m\e[1m'warning:$'\e[0m' devenv inactive - activating temporary shell...
		echo "  run 'dev shell' to enter a persistent shell, or"
		echo "  run 'dev configure --auto-activate=true' to enter the shell automatically with direnv (recommended)"
		echo ""
	fi
	nix develop . --no-warn-dirty --impure -c $SHELL -c "dev $(printf '\"%s\" ' "${@}")"
	exit 0
fi
