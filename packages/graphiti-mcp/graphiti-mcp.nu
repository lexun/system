# graphiti-mcp: Manage Graphiti MCP server with FalkorDB

const OP_ITEM_ID = "h4hlt6o5gisjitk2iinjh7h7ya"
const ENV_FILE = "~/.local/share/graphiti-mcp/.env"

def main [
  command?: string  # start, stop, status, logs, restart, clean, update, fetch-key
  --follow (-f)     # Follow logs (for logs command)
] {
  let cmd = ($command | default "help")
  let data_dir = $"($env.HOME)/.local/share/graphiti-mcp"
  let compose_file = $COMPOSE_FILE
  let env_file = ($ENV_FILE | path expand)

  # Ensure data directory exists
  mkdir $data_dir

  # Create default .env if it doesn't exist
  if not ($env_file | path exists) {
    [
      "# Graphiti MCP Configuration"
      "# Get your OpenAI API key from https://platform.openai.com/api-keys"
      "OPENAI_API_KEY="
      "FALKORDB_PASSWORD="
      "GRAPHITI_GROUP_ID=main"
      ""
    ] | str join "\n" | save $env_file
    print $"Created ($env_file) - please add your OPENAI_API_KEY"
  }

  # Base docker compose args
  let dc_args = [-f $compose_file --env-file $env_file -p graphiti-mcp]

  match $cmd {
    "start" => {
      # Check if OPENAI_API_KEY is set
      let env_content = (open $env_file)
      if ($env_content | str contains "OPENAI_API_KEY=\n") or ($env_content | str contains "OPENAI_API_KEY=$") {
        print $"(ansi red)Error: OPENAI_API_KEY not set in ($env_file)(ansi reset)"
        print "Run 'graphiti-mcp fetch-key' to fetch from 1Password"
        exit 1
      }

      print "Starting Graphiti MCP server..."
      docker compose ...$dc_args up -d
      print ""
      print $"(ansi green)Graphiti MCP is running:(ansi reset)"
      print $"  FalkorDB:     redis://localhost:6379"
      print $"  FalkorDB UI:  http://localhost:3030"
      print $"  MCP Server:   http://localhost:8000/mcp/"
      print $"  Health:       http://localhost:8000/health"
      print ""
      print $"Config: ($env_file)"
    }
    "stop" => {
      print "Stopping Graphiti MCP server..."
      docker compose ...$dc_args down
    }
    "restart" => {
      docker compose ...$dc_args restart
    }
    "status" => {
      docker compose ...$dc_args ps
    }
    "logs" => {
      if $follow {
        docker compose ...$dc_args logs -f
      } else {
        docker compose ...$dc_args logs --tail 100
      }
    }
    "clean" => {
      print $"(ansi yellow)This will remove all Graphiti data!(ansi reset)"
      let confirm = (input "Are you sure? [y/N]: ")
      if ($confirm | str downcase) == "y" {
        docker compose ...$dc_args down -v
        print "Volumes removed."
      } else {
        print "Cancelled."
      }
    }
    "update" => {
      print "Pulling latest image..."
      docker compose ...$dc_args pull
      docker compose ...$dc_args up -d
    }
    "fetch-key" => {
      print "Fetching OpenAI key from 1Password..."
      let key = (op item get $OP_ITEM_ID --fields credential --format json | from json | get value)

      # Read current .env and update OPENAI_API_KEY
      let env_content = (open $env_file)
      let updated = ($env_content | str replace -r 'OPENAI_API_KEY=.*' $"OPENAI_API_KEY=($key)")
      $updated | save -f $env_file

      print $"(ansi green)OpenAI key saved to ($env_file)(ansi reset)"
    }
    "help" => {
      print "graphiti-mcp - Manage Graphiti MCP server with FalkorDB"
      print ""
      print "Commands:"
      print "  start      Start the server"
      print "  stop       Stop the server"
      print "  restart    Restart the server"
      print "  status     Show container status"
      print "  logs       Show recent logs (use -f to follow)"
      print "  update     Pull latest image and restart"
      print "  clean      Remove all data (with confirmation)"
      print "  fetch-key  Fetch OpenAI key from 1Password"
      print ""
      print $"Config: ($env_file)"
    }
    _ => {
      print $"Unknown command: ($cmd)"
      print "Run 'graphiti-mcp help' for usage"
      exit 1
    }
  }
}
