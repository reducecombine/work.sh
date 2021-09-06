cd "${BASH_SOURCE%/*}/.."

slack_presence(){
  # How to get a token:
  # 1.- create an app ("How to quickly get and use a Slack API token") https://api.slack.com/tutorials/tracks/getting-a-token
  #   - add users.profile:write scope to it
  # 2.- install said app to your Slack workspace (it's not org-wide, so it's safe to do)
  # 3.- visit OAuth and Permissions i.e. https://api.slack.com/apps/<YOUR_APP_ID>/oauth
  #   - copy *user* token (will show up after adding at least one scope to User Token Scopes)

  # Note that the Slack API returns 200 on validation errors.

  # Ensures Homebrew `curl` is used, since macOS curl lacks `--fail-with-body`:
  chronic /usr/local/opt/curl/bin/curl --show-error --fail-with-body \
          -X POST -H "Authorization: Bearer $SLACK_TOKEN"  \
          -H 'Content-type: application/json' \
          --data "$1" https://slack.com/api/users.setPresence
}

slack_status(){
  chronic /usr/local/opt/curl/bin/curl --show-error --fail-with-body \
          -X POST -H "Authorization: Bearer $SLACK_TOKEN"\
          -H 'Content-type: application/json' \
          --data "$1" https://slack.com/api/users.profile.set
}

slack_on(){
  slack_presence '{"presence": "auto"}'
  slack_status '
{
    "profile": {
        "status_text": "",
        "status_emoji": "",
        "status_expiration": 0
    }
}
'
}

slack_off(){
  slack_presence '{"presence": "away"}'
  slack_status '
{
    "profile": {
        "status_text": "Focusing (or at least a script says so), may not be looking at Slack. Github/Email preferred.",
        "status_emoji": ":construction:",
        "status_expiration": 0
    }
}
'
}

flush_dns_cache(){
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

space_script="$(echo $PWD/spaceID)"

if [[ ! -e $space_script ]] ; then
  gcc -o spaceID spaceID.m -framework Foundation -framework Carbon || exit 1
fi

is_first_space(){
  # I have two assumptions:
  # 1 (personal) -  the first macOS space is work-related
  # 2 (technical) - the first macOS space has no id, per $space_script.
  #                 Spaces other than the first have a UUID, so the `grep`ing would fail.
  $space_script | grep --silent XXXXXX
}

function ctrl_c() {
  osascript -e 'tell application "Thyme" to stop'

  slack_on
  open focus://unfocus

  # Avoid an ugly ^C followed by other output:
  echo

  echo "Done"
  exit 0
}


if ! is_first_space; then
  echo "Must be launched from the first space (or space detection failed)"
else

  trap ctrl_c INT

  osascript -e 'tell application "Thyme" to start'
  slack_off
  open focus://focus

  echo "Started"

  while true; do
    # Sleep a small amount for fast feedback.
    # Note that lower values can leave macOS in a unusable state
    # (especially if we remove the is_first_space check)
    sleep 0.65

    # Avoid needless keypresses, since they otherwise interfere with user keystrokes/clicks.
    if ! is_first_space; then
      # Press "Control 0" (switch to desktop 1) which is my work desktop.
      # Please make sure you have this shortcut as well.
      # See: https://apple.stackexchange.com/a/213566
      osascript -e 'tell application "System Events" to key code 29 using (control down)'
    fi
  done

fi
