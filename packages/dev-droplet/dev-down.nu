# Destroy the dev droplet (keeps volume and reserved IP)

def main [] {
  let infra_dir = $"($env.HOME)/.infra/terraform"

  if not ($infra_dir | path exists) {
    print $"(ansi red)Error:(ansi reset) ~/.infra not found"
    print "Clone it with: git clone git@github.com:lexun/infra.git ~/.infra"
    exit 1
  }

  # Get DO token from 1Password
  print $"(ansi cyan)Fetching DO token from 1Password...(ansi reset)"
  let do_token = (op read "op://Private/digitalocean.com/admin" | str trim)

  if ($do_token | is-empty) {
    print $"(ansi red)Error:(ansi reset) Could not fetch DO token from 1Password"
    exit 1
  }

  # Get SSH key fingerprint
  let ssh_fingerprint = "6f:9a:79:89:7d:ec:d4:86:02:68:92:d2:60:92:4b:be"

  cd $infra_dir

  # Apply with droplet disabled
  print $"(ansi cyan)Destroying droplet \(keeping volume and IP\)...(ansi reset)"
  (tofu apply
    -var $"do_token=($do_token)"
    -var $"ssh_key_fingerprint=($ssh_fingerprint)"
    -var "droplet_enabled=false"
    -var "region=sfo3"
    -var "droplet_size=s-4vcpu-8gb"
    -auto-approve)

  print $"(ansi green)Droplet destroyed.(ansi reset)"
  print "Volume and reserved IP retained."
  print "Run 'dev-up' to recreate."
}
