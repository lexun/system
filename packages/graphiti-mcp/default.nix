{
  writers,
  fetchurl,
  runCommand,
  gnused,
}:

let
  version = "0.24.1";

  dockerComposeRaw = fetchurl {
    url = "https://raw.githubusercontent.com/getzep/graphiti/v${version}/mcp_server/docker/docker-compose.yml";
    hash = "sha256-zO46+LvTMa2XR9b3QNut6VRJfEnDxohroSZLwP9lJ6E=";
  };

  # Patch the compose file to:
  # 1. Remove env_file directive (which uses relative path)
  # 2. Add OPENAI_API_KEY to environment section for substitution via --env-file
  # 3. Change FalkorDB UI port from 3000 to 3030 (avoid conflict with dev servers)
  dockerCompose = runCommand "docker-compose.yml" { } ''
    ${gnused}/bin/sed \
      -e '/env_file:/,/required:/d' \
      -e 's/environment:/environment:\n      - OPENAI_API_KEY=''${OPENAI_API_KEY}/' \
      -e 's/"3000:3000"/"3030:3000"/' \
      ${dockerComposeRaw} > $out
  '';
in
writers.writeNuBin "graphiti-mcp" ''
  const COMPOSE_FILE = "${dockerCompose}"

  ${builtins.readFile ./graphiti-mcp.nu}
''
