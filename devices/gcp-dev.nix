{ inputs }:

let
  inherit (inputs) nixpkgs home-manager;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.vibetree.overlays.default
    ];
  };

  # Keeps the GCP secret `claude-oauth-credentials` in step with the local
  # Claude credentials file. Agent pods read that secret at startup, so when
  # it goes stale every dispatched worker dies on an expired token and the
  # pipeline has to be halted by hand until someone re-runs /login.
  #
  # Replaces an out-of-band `*/30 * * * * /tmp/refresh-creds.sh` crontab entry
  # (added 2026-05-03, script since lost to a reboot clearing /tmp). That was
  # also a local privilege-escalation path: /tmp is world-writable and this
  # user has passwordless sudo, so anyone able to create that one path got
  # root within 30 minutes. Declaring it here makes it reproducible and moves
  # the executable somewhere unprivileged users cannot write.
  claudeCredsSync = pkgs.writeShellApplication {
    name = "claude-creds-sync";
    runtimeInputs = with pkgs; [ google-cloud-sdk jq coreutils ];
    text = ''
      cred="$HOME/.claude/.credentials.json"
      secret="claude-oauth-credentials"
      project="memex-orchestration"

      if [ ! -r "$cred" ]; then
        echo "no credentials file at $cred; nothing to sync"
        exit 0
      fi

      # Compare the meaningful fields rather than raw bytes: formatting and
      # trailing-newline differences would otherwise mint a new secret version
      # on every single run.
      fingerprint() {
        jq -S -c '.claudeAiOauth | {accessToken, refreshToken, expiresAt}'
      }

      if ! local_fp="$(fingerprint < "$cred" 2>/dev/null)" \
         || [ "$local_fp" = "null" ]; then
        echo "credentials file is not in the expected shape; refusing to push" >&2
        exit 1
      fi

      # Never overwrite a good stored secret with an already-dead token.
      expires_at="$(jq -r '.claudeAiOauth.expiresAt // 0' "$cred")"
      now_ms="$(( $(date +%s) * 1000 ))"
      if [ "$expires_at" -le "$now_ms" ]; then
        echo "local credentials already expired; refusing to push"
        exit 0
      fi

      remote_fp=""
      if remote="$(gcloud secrets versions access latest \
            --secret="$secret" --project="$project" 2>/dev/null)"; then
        remote_fp="$(printf '%s' "$remote" | fingerprint 2>/dev/null || true)"
      fi

      if [ "$local_fp" = "$remote_fp" ]; then
        echo "secret already matches local credentials; no new version"
        exit 0
      fi

      gcloud secrets versions add "$secret" \
        --data-file="$cred" --project="$project" >/dev/null
      echo "pushed new credential version; expires in $(( (expires_at - now_ms) / 3600000 ))h"
    '';
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    onePasswordEnabled = false;
    enableSshConfig = false;
    inherit inputs;
    nixvim = inputs.nixvim;
  };
  modules = [
    ../modules/home-manager
    {
      home.username = "luke";
      home.homeDirectory = pkgs.lib.mkForce "/home/luke";
      # Non-NixOS Linux: `system-update` activates home-manager standalone and
      # needs to know which homeConfiguration this device is. Hostname is "dev",
      # which collides with nixosConfigurations."dev", so declare it explicitly.
      #
      # A file rather than a sessionVariable: home-manager writes sessionVariables
      # to hm-session-vars.sh, which nushell (the login shell here) never sources.
      home.file.".config/system/hm-config".text = "gcp-dev";
      home.packages = with pkgs; [
        _1password-cli
        less
        vibetree
        claudeCredsSync
      ];

      # Push refreshed Claude credentials to GCP Secret Manager on a timer.
      # Runs as a user unit so it inherits this user's gcloud login; it needs
      # no privileges beyond that.
      systemd.user.services.claude-creds-sync = {
        Unit.Description = "Sync local Claude credentials to GCP Secret Manager";
        Service = {
          Type = "oneshot";
          ExecStart = "${claudeCredsSync}/bin/claude-creds-sync";
        };
      };

      systemd.user.timers.claude-creds-sync = {
        Unit.Description = "Periodic Claude credential sync";
        Timer = {
          # Claude refreshes the access token well inside its lifetime, so a
          # half-hourly check keeps the secret current without churning
          # versions — the unit no-ops when nothing changed.
          OnBootSec = "3min";
          OnUnitActiveSec = "30min";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    }
  ];
}
