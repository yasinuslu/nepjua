{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Script to export GPG private key to 1Password
  exportGpgTo1Password = pkgs.writeShellScriptBin "export-gpg-to-1password" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Check if 1Password CLI is installed and authenticated
    if ! command -v op &> /dev/null; then
      echo "Error: 1Password CLI (op) is not installed or not in PATH"
      exit 1
    fi

    # Check if op is authenticated
    if ! op account get &> /dev/null; then
      echo "Error: 1Password CLI is not authenticated. Please run 'op signin' first."
      exit 1
    fi

    # Check if GPG is installed
    if ! command -v gpg &> /dev/null; then
      echo "Error: GPG is not installed or not in PATH"
      exit 1
    fi

    # Parse arguments
    KEY_ID=""
    VAULT="Private"
    ITEM_NAME=""

    while [[ $# -gt 0 ]]; do
      case $1 in
        --key-id)
          KEY_ID="$2"
          shift 2
          ;;
        --vault)
          VAULT="$2"
          shift 2
          ;;
        --name)
          ITEM_NAME="$2"
          shift 2
          ;;
        *)
          echo "Unknown option: $1"
          echo "Usage: export-gpg-to-1password --key-id KEY_ID [--vault VAULT] [--name ITEM_NAME]"
          exit 1
          ;;
      esac
    done

    if [[ -z "$KEY_ID" ]]; then
      echo "Error: --key-id is required"
      echo "Usage: export-gpg-to-1password --key-id KEY_ID [--vault VAULT] [--name ITEM_NAME]"
      exit 1
    fi

    # Get key info
    KEY_INFO=$(gpg --list-keys --with-colons "$KEY_ID" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      echo "Error: GPG key $KEY_ID not found"
      exit 1
    fi

    # Extract user ID for naming if not provided
    if [[ -z "$ITEM_NAME" ]]; then
      USER_ID=$(echo "$KEY_INFO" | grep "^uid" | head -n1 | cut -d: -f10)
      ITEM_NAME="GPG Key - $USER_ID"
    fi

    echo "Exporting GPG key $KEY_ID to 1Password vault '$VAULT' as '$ITEM_NAME'..."

    # Export public key
    PUBLIC_KEY=$(gpg --armor --export "$KEY_ID")
    if [[ -z "$PUBLIC_KEY" ]]; then
      echo "Error: Failed to export public key"
      exit 1
    fi

    # Export private key (with armor)
    PRIVATE_KEY=$(gpg --armor --export-secret-keys "$KEY_ID")
    if [[ -z "$PRIVATE_KEY" ]]; then
      echo "Error: Failed to export private key"
      exit 1
    fi

    # Create or update item in 1Password
    if op item get "$ITEM_NAME" --vault "$VAULT" &>/dev/null; then
      echo "Updating existing 1Password item '$ITEM_NAME'..."
      op item edit "$ITEM_NAME" --vault "$VAULT" \
        "public-key[text]=$PUBLIC_KEY" \
        "private-key[text]=$PRIVATE_KEY" \
        "key-id[text]=$KEY_ID"
    else
      echo "Creating new 1Password item '$ITEM_NAME'..."
      op item create --category "Secure Note" --vault "$VAULT" \
        --title "$ITEM_NAME" \
        "public-key[text]=$PUBLIC_KEY" \
        "private-key[text]=$PRIVATE_KEY" \
        "key-id[text]=$KEY_ID"
    fi

    echo "GPG key successfully exported to 1Password!"
  '';

  # Script to import GPG private key from 1Password
  importGpgFrom1Password = pkgs.writeShellScriptBin "import-gpg-from-1password" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Check if 1Password CLI is installed and authenticated
    if ! command -v op &> /dev/null; then
      echo "Error: 1Password CLI (op) is not installed or not in PATH"
      exit 1
    fi

    # Check if op is authenticated
    if ! op account get &> /dev/null; then
      echo "Error: 1Password CLI is not authenticated. Please run 'op signin' first."
      exit 1
    fi

    # Check if GPG is installed
    if ! command -v gpg &> /dev/null; then
      echo "Error: GPG is not installed or not in PATH"
      exit 1
    fi

    # Parse arguments
    ITEM_NAME=""
    VAULT="Private"
    TRUST_LEVEL="ultimate"

    while [[ $# -gt 0 ]]; do
      case $1 in
        --name)
          ITEM_NAME="$2"
          shift 2
          ;;
        --vault)
          VAULT="$2"
          shift 2
          ;;
        --trust)
          TRUST_LEVEL="$2"
          shift 2
          ;;
        *)
          echo "Unknown option: $1"
          echo "Usage: import-gpg-from-1password --name ITEM_NAME [--vault VAULT] [--trust TRUST_LEVEL]"
          exit 1
          ;;
      esac
    done

    if [[ -z "$ITEM_NAME" ]]; then
      echo "Error: --name is required"
      echo "Usage: import-gpg-from-1password --name ITEM_NAME [--vault VAULT] [--trust TRUST_LEVEL]"
      exit 1
    fi

    echo "Importing GPG key from 1Password item '$ITEM_NAME' in vault '$VAULT'..."

    # Get private key from 1Password
    PRIVATE_KEY=$(op item get "$ITEM_NAME" --vault "$VAULT" --fields private-key)
    if [[ -z "$PRIVATE_KEY" ]]; then
      echo "Error: Failed to retrieve private key from 1Password"
      exit 1
    fi

    # Import private key to GPG
    echo "$PRIVATE_KEY" | gpg --batch --import

    # Get key ID from 1Password
    KEY_ID=$(op item get "$ITEM_NAME" --vault "$VAULT" --fields key-id)
    if [[ -n "$KEY_ID" ]]; then
      # Set trust level
      echo "Setting trust level to $TRUST_LEVEL for key $KEY_ID..."
      echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key "$KEY_ID" trust
    fi

    echo "GPG key successfully imported from 1Password!"
  '';

  # Script to generate a new GPG key and store it in 1Password
  generateGpgKey = pkgs.writeShellScriptBin "generate-gpg-key" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Check if 1Password CLI is installed and authenticated
        if ! command -v op &> /dev/null; then
          echo "Error: 1Password CLI (op) is not installed or not in PATH"
          exit 1
        fi

        # Check if op is authenticated
        if ! op account get &> /dev/null; then
          echo "Error: 1Password CLI is not authenticated. Please run 'op signin' first."
          exit 1
        fi

        # Check if GPG is installed
        if ! command -v gpg &> /dev/null; then
          echo "Error: GPG is not installed or not in PATH"
          exit 1
        fi

        # Parse arguments
        NAME=""
        EMAIL=""
        COMMENT=""
        EXPIRY="0"
        KEY_TYPE="ed25519"
        KEY_LENGTH="4096"
        VAULT="Private"
        ITEM_NAME=""

        while [[ $# -gt 0 ]]; do
          case $1 in
            --name)
              NAME="$2"
              shift 2
              ;;
            --email)
              EMAIL="$2"
              shift 2
              ;;
            --comment)
              COMMENT="$2"
              shift 2
              ;;
            --expiry)
              EXPIRY="$2"
              shift 2
              ;;
            --key-type)
              KEY_TYPE="$2"
              shift 2
              ;;
            --key-length)
              KEY_LENGTH="$2"
              shift 2
              ;;
            --vault)
              VAULT="$2"
              shift 2
              ;;
            --item-name)
              ITEM_NAME="$2"
              shift 2
              ;;
            *)
              echo "Unknown option: $1"
              echo "Usage: generate-gpg-key --name NAME --email EMAIL [options]"
              exit 1
              ;;
          esac
        done

        if [[ -z "$NAME" || -z "$EMAIL" ]]; then
          echo "Error: --name and --email are required"
          echo "Usage: generate-gpg-key --name NAME --email EMAIL [options]"
          exit 1
        fi

        if [[ -z "$ITEM_NAME" ]]; then
          ITEM_NAME="GPG Key - $NAME <$EMAIL>"
        fi

        # Create batch file for key generation
        BATCH_FILE=$(mktemp)
        trap "rm -f $BATCH_FILE" EXIT

        # Determine key algorithm parameters
        if [[ "$KEY_TYPE" == "ed25519" ]]; then
          KEY_ALGO="default"
        elif [[ "$KEY_TYPE" == "rsa" ]]; then
          KEY_ALGO="rsa$KEY_LENGTH"
        else
          echo "Error: Unsupported key type: $KEY_TYPE"
          exit 1
        fi

        # Create batch file content
        cat > "$BATCH_FILE" <<EOF
    %echo Generating GPG key
    Key-Type: $KEY_TYPE
    Key-Length: $KEY_LENGTH
    Key-Algo: $KEY_ALGO
    Name-Real: $NAME
    Name-Email: $EMAIL
    EOF

        if [[ -n "$COMMENT" ]]; then
          echo "Name-Comment: $COMMENT" >> "$BATCH_FILE"
        fi

        cat >> "$BATCH_FILE" <<EOF
    Expire-Date: $EXPIRY
    %commit
    %echo Key generation completed
    EOF

        echo "Generating GPG key for $NAME <$EMAIL>..."
        gpg --batch --generate-key "$BATCH_FILE"

        # Get the key ID of the newly generated key
        KEY_ID=$(gpg --list-secret-keys --with-colons "$EMAIL" | grep "^sec" | head -n1 | cut -d: -f5)
        if [[ -z "$KEY_ID" ]]; then
          echo "Error: Failed to get key ID for the newly generated key"
          exit 1
        fi

        echo "Key generated with ID: $KEY_ID"
        echo "Exporting to 1Password..."

        # Export to 1Password
        export-gpg-to-1password --key-id "$KEY_ID" --vault "$VAULT" --name "$ITEM_NAME"

        echo "GPG key generation and export completed successfully!"
  '';

  # Script to list GPG keys stored in 1Password
  listGpgKeysIn1Password = pkgs.writeShellScriptBin "list-gpg-keys-in-1password" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Check if 1Password CLI is installed and authenticated
    if ! command -v op &> /dev/null; then
      echo "Error: 1Password CLI (op) is not installed or not in PATH"
      exit 1
    fi

    # Check if op is authenticated
    if ! op account get &> /dev/null; then
      echo "Error: 1Password CLI is not authenticated. Please run 'op signin' first."
      exit 1
    fi

    # Parse arguments
    VAULT="Private"

    while [[ $# -gt 0 ]]; do
      case $1 in
        --vault)
          VAULT="$2"
          shift 2
          ;;
        *)
          echo "Unknown option: $1"
          echo "Usage: list-gpg-keys-in-1password [--vault VAULT]"
          exit 1
          ;;
      esac
    done

    echo "Listing GPG keys stored in 1Password vault '$VAULT'..."

    # List items with "GPG Key" in the title
    op item list --vault "$VAULT" --categories "Secure Note" | grep -i "GPG Key" || echo "No GPG keys found in vault '$VAULT'"
  '';
in
{
  home.packages = with pkgs; [
    # Add the custom scripts
    exportGpgTo1Password
    importGpgFrom1Password
    generateGpgKey
    listGpgKeysIn1Password
  ];

  # Documentation
  home.file.".local/share/gpg-1password/README.md" = {
    text = ''
      # GPG and 1Password Integration

      This module provides tools to manage GPG keys with 1Password integration.

      ## Available Commands

      ### Generate a new GPG key and store it in 1Password

      ```bash
      generate-gpg-key --name "Your Name" --email "your.email@example.com" [options]
      ```

      Options:
      - `--name NAME`: Your real name (required)
      - `--email EMAIL`: Your email address (required)
      - `--comment COMMENT`: Optional comment for the key
      - `--expiry DAYS`: Key expiration in days (0 = no expiry)
      - `--key-type TYPE`: Key type (ed25519 or rsa, default: ed25519)
      - `--key-length LENGTH`: Key length for RSA keys (default: 4096)
      - `--vault VAULT`: 1Password vault to store the key (default: Private)
      - `--item-name NAME`: Custom name for the 1Password item

      ### Export an existing GPG key to 1Password

      ```bash
      export-gpg-to-1password --key-id KEY_ID [options]
      ```

      Options:
      - `--key-id KEY_ID`: GPG key ID to export (required)
      - `--vault VAULT`: 1Password vault to store the key (default: Private)
      - `--name NAME`: Custom name for the 1Password item

      ### Import a GPG key from 1Password

      ```bash
      import-gpg-from-1password --name ITEM_NAME [options]
      ```

      Options:
      - `--name ITEM_NAME`: Name of the 1Password item (required)
      - `--vault VAULT`: 1Password vault to retrieve the key from (default: Private)
      - `--trust LEVEL`: Trust level for the imported key (default: ultimate)

      ### List GPG keys stored in 1Password

      ```bash
      list-gpg-keys-in-1password [--vault VAULT]
      ```

      Options:
      - `--vault VAULT`: 1Password vault to list keys from (default: Private)

      ## Example Workflow

      1. Generate a new GPG key and store it in 1Password:
         ```bash
         generate-gpg-key --name "John Doe" --email "john.doe@example.com"
         ```

      2. On a new machine, import your GPG key from 1Password:
         ```bash
         import-gpg-from-1password --name "GPG Key - John Doe <john.doe@example.com>"
         ```

      3. List all your GPG keys stored in 1Password:
         ```bash
         list-gpg-keys-in-1password
         ```
    '';
    onChange = ''
      mkdir -p "$HOME/.local/share/gpg-1password"
    '';
  };
}
