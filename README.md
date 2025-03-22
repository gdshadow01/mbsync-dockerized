# mbsync-dockerized
mbsync in docker with option to backup several accounts, optionally auto-generate config for mbsync from docker-compose or use own config and easy restore to remote account.

I needed an offline backup solution for my IMAP mail accounts that
- lets me choose the storage folder
- lets me restore to a remote target
- supports multiple accounts
- is dockerized
- creates a config file for mbsync from docker-compose.yml

As I could't find that:

This project aims to spin up a docker container with mbsync. Accounts and basic settings for mbsync can be defined in the docker-compose file. A config file for mbsync will then be auto-generated from the docker-compose if no config file is provided. If a config file is provided, it will be used without changes. 

The mbsync config file and the mail folder are exposed as bind mounts. Up to 10 mail accounts can be auto-generated. 

See comments in docker-compose.yml for more information.

## Usage: 
- `git clone https://github.com/gdshadow01/mbsync-dockerized.git && cd mbsync-dockerized`
- set up mail account(s) in docker-compose.yml and change variables if needed (see https://isync.sourceforge.io/mbsync.html for options)
- `docker compose build`
- optional: provide mbsync.rc at /config mount point
- `docker compose up` for running in foreground or `docker compose up -d` when running in background (as daemon, see docker-compose.yml)

## other solutions
- docker-mbsync by JakeWharthon: `https://github.com/JakeWharton/docker-mbsync`
- mbsync by jon6fingrs: `https://github.com/jon6fingrs/mbsync/tree/main`
