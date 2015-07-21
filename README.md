# gofed-utils
A pack of tools for gofed

## gofed-notify.sh

A simple Bash script for updates notification. This script should be run with root
permissions, it modifies local gofed database.

#### Requirements

* gofed - https://github.com/ingvagabund/gofed
* bash
* configured `xmail` for e-mail notifications

##### Examples:

Update and send report to listed e-mail addresses:
  ```bash
  # ./gofed-notify.sh email foo1@bar foo2bar foo3@bar
  ```

Update and store report in file `log.txt`:
  ```
  # ./gofed-notify.sh print log.txt
  ```

See `help` for more info:
  ```
  # ./gofed-notify.sh help
  ```
