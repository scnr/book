# Dependencies

## Engine

Due to the use of [Chrome](https://www.google.com/chrome/), there are external 
dependencies that need to be met.

### Debian

```
sudo apt-get update
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb
```

### Other

Please use the package manager of your OS to install the Chrome and its dependencies.

## Pro Web UI

For the Pro interface the [PostgreSQL](https://www.postgresql.org/) DB is required.

### Debian

```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql.service
```

### Other

Please use the package manager of your OS to install the
[PostgreSQL](https://www.postgresql.org/) and its dependencies.
