# mbsync-dockerized
mbsync in docker with option for several accounts, auto-generated config  from compose, option to use own config and restore.

I needed a offline backup solution for my mail accounts that
- lets me choose the storage folder
- lets me restore to a remote target
- supports multiple accounts
- is open-source and stable
- is dockerized

As I could't find that:

This project aims to spin up a docker container with mbsync. Accounts and basic settings can be set up in the docker-compose file. A config file for mbsync will be auto-generated from the docker-compose if no config file is provided. Alternatively a provided config file is used. 

The mbsync config file and the mail folder are exposed as bind mounts. Up to 9 mail accounts can be auto-generated. 

See comments in docker-compose.example for more information.

Usage: 
- To-Do
