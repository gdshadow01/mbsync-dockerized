#!/bin/bash
set -e

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

## Loop through accounts

for i in $(seq 1 10); do
    eval "PASS=\$ACCOUNT${i}_PASS"
    if [ -n "$PASS" ]; then
        # Create the script file
        echo "#!/bin/sh" > "/scripts/pass_cmd_${i}.sh"

        # Escape all special characters in the password
        ESCAPED_PASS=$(printf '%s' "$PASS" | sed 's/[\\"$`]/\\&/g')

        # Write the echo command with the escaped password
        echo "echo \"$ESCAPED_PASS\"" >> "/scripts/pass_cmd_${i}.sh"
        chmod +x "/scripts/pass_cmd_${i}.sh"
    fi
done

# find or create config file
CONFIG_FILE="/config/mbsync.rc"
if [ -f "$CONFIG_FILE" ]; then
    log "Found config file, skipping creation and using that instead."
    CONFIG_FILE="/config/mbsync.rc"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p /config
    echo "# Generated mbsync configuration" > "$CONFIG_FILE"

    # Loop through environment variables to detect accounts
    for i in $(seq 1 10); do
      eval "EMAIL=\$ACCOUNT${i}_EMAIL"
      eval "IMAP_HOST=\$ACCOUNT${i}_IMAP_HOST"
      eval "SSL_TYPE=\$ACCOUNT${i}_SSL_TYPE"
      eval "SSL_VERSIONS=\$ACCOUNT${i}_SSL_VERSIONS"
      eval "SUBFOLDERS=\$ACCOUNT${i}_SUBFOLDERS"
      eval "SYNC_MODE=\$ACCOUNT${i}_SYNC_MODE"
      eval "SYNC_STATE=\$ACCOUNT${i}_SYNC_STATE"
      eval "CREATE=\$ACCOUNT${i}_CREATE"
      eval "EXPUNGE=\$ACCOUNT${i}_EXPUNGE"
      eval "PATTERNS=\$ACCOUNT${i}_PATTERNS"

      # If EMAIL is empty, stop processing
      [ -z "$EMAIL" ] && break

      # Derive MAILDIR_PATH from EMAIL
      MAILDIR_PATH="/Mail/$EMAIL/"

      cat <<EOF >> "$CONFIG_FILE"

IMAPAccount $EMAIL
Host $IMAP_HOST
User $EMAIL
PassCmd "/scripts/pass_cmd_${i}.sh"  # Use PassCmd to retrieve the password
SSLType $SSL_TYPE
SSLVersions $SSL_VERSIONS

IMAPStore ${EMAIL}-remote
Account $EMAIL

MaildirStore ${EMAIL}-local
Path $MAILDIR_PATH
Inbox ${MAILDIR_PATH}INBOX
SubFolders $SUBFOLDERS

Channel $EMAIL
Far :${EMAIL}-remote:
Near :${EMAIL}-local:
Patterns $PATTERNS
Create $CREATE
Expunge $EXPUNGE
Sync $SYNC_MODE
SyncState $SYNC_STATE

EOF
    done

    echo "Generated configuration at $CONFIG_FILE"
fi

# make sure maildirs exist
ensure_maildir() {
    local maildir_base="/Mail"
    log "Ensuring Maildir structure exists in $maildir_base..."

    grep -E '^MaildirStore ' "$CONFIG_FILE" | while read -r line; do
        store_name=$(echo "$line" | awk '{print $2}')
        store_path=$(grep -A1 "^MaildirStore $store_name" "$CONFIG_FILE" | grep '^Path' | awk '{print $2}')

        if [ -n "$store_path" ]; then
            absolute_path=$(eval echo "$store_path")  # Expand ~ and variables

            if [ ! -d "$absolute_path" ]; then
                log "Creating missing Maildir directory: $absolute_path"
                if mkdir -p "$absolute_path"; then
                    chmod -R 700 "$absolute_path"
                    log "Set permissions: 700 on $absolute_path"
                else
                    log "ERROR: Failed to create directory $absolute_path"
                fi
            else
                log "Directory already exists: $absolute_path"
            fi
        else
            log "WARNING: No path found for MaildirStore $store_name"
        fi
    done
}

ensure_maildir  # create dir

# run mbsync
run_mbsync() {
    log "Running mbsync..."
    mbsync -c "$CONFIG_FILE" -a
### below debug only, uncomment line above to not run mbsync or add -V for more info
#    tail -f /dev/null
}

if [ "${1}" = "daemon" ]; then
    INTERVAL=${2:-300}
    log "Starting in daemon mode with sync interval of $INTERVAL seconds..."
    while true; do
        run_mbsync
        log "Sleeping for $INTERVAL seconds..."
        sleep "$INTERVAL"
    done
else
    run_mbsync
fi

