# Added to support tooling like the Nix Env Selector for VS Code, which allows
# editor plugins to access pacakges like formatters from the dev env.
# https://marketplace.visualstudio.com/items?itemName=arrterian.nix-env-selector
(builtins.getFlake ("git+file://" + toString ./.)
).devShells.${builtins.currentSystem}.default
