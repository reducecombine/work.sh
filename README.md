A script for focusing on work, blocking non-work stuff. The idea is to forbid mindless app/website context-switching while you're focused.

Once you're done, all blocked things are restored.

I find this workflow a middle ground between "block this specific thing forever" (which may only be sustainable for a season) and "don't block it" (which can excessively depend on willpower). In other words, _temporary_ blocking is particularly fine-grained.

Since N things are blocked/unblocked at once, one gets to fiddle less with configs or UIs, so one is encouraged to focus more often and more heavily.

These are the techniques/apps being composed:

## On focus in

* Continuously ensures you're in a specific macOS [space](https://support.apple.com/guide/mac-help/work-in-multiple-spaces-mh14112/mac)
  * I use the first space as a 'coding work' space (the other two ones being 'work communications' [mainly Slack] and 'personal')
  * [Contexts.app](https://contexts.co/) makes macOS spaces actually useful.
    * Specifically you can use it to restrict command-tab on a per-space basis.
  * So, as soon as you switch to another space, the script will switch back to the targeted space.
* Starts [Thyme.app](https://joaomoreno.github.io/thyme/)
  * It's a simple timer, it saves all timing history.
  * Normally I work in batches of ~1h; this way I can know if I'm undershooting / overshooting.
* Starts [Focus.app](https://heyfocus.com/)
  * Blocks selected websites and applications.
* Marks you on Slack as absent
  * So that people will (hopefully) ping you less
* Sets a custom Slack status explaining the prior point

## On focus out

All previous steps are undone.

## Requisites

`gcc` should be accessible (I think it's XCode that installs it).

```bash
# ensure latest:
brew install curl
# for `chronic` (which is not essential - can be stripped from the script): 
brew install moreutils
```

Ensure the `Control + 0` shortcut is bound to "Switch to Desktop 1" (see https://apple.stackexchange.com/a/213566). 

## Usage

Clone this repo.

Reading the source is recommended - never run blindly scripts from the internet!

Run from a terminal:

```sh
# Token obtention is described in source
SLACK_TOKEN=... work.sh
```

...and leave that process open. (Normally I have a bunch of persistent tabs anyway, like Docker or a REPL. So it's not too obstrusive)

Ctrl-C will cleanly undo all effects and exit.

## Notes

I don't use this script as-is; my copy has extra goodies. For example I also copy a restrictive hosts file to `/etc/hosts` on "focus in" and undo it later.

(For that reason the `flush_dns_cache` helper is bundled)

## Credits

Uses a modified version of https://github.com/alt-jero/McSpaces, which in turn is based on https://archive.is/fy4JQ
