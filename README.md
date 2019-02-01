# pic-sure-i2b2-transmart
A docker-compose orchestrated research infrastructure powered by PIC-SURE and i2b2/tranSMART. This serves as a reference implementation for use in production environments where the databases reside off the application server.

# Installation

On a new server, or docker machine, run the following commands to install and start up the whole stack. It requires privileges to the GitHub repo and to be able run `docker` commands on the machine itself.

```

alias dcom='docker-compose --file /var/tmp/pic-sure-i2b2-transmart/docker-compose.yml'

cd /var/tmp
rm -fR pic-sure-i2b2-transmart
git clone https://github.com/hms-dbmi/pic-sure-i2b2-transmart.git
cd pic-sure-i2b2-transmart/
git checkout master-httpd-workaround

dcom  down
dcom pull
dcom build
dcom up -d

cd httpd/utilities
./index.sh
cd ..

```

If all commands run successfully, navigate your desktop browser to the public IP address of the instance (or to the docker-machine's IP address, if you are running this stack locally).

The initial page should display some docker specific information and the installed services, and their corresponding images. Links are also provided to the configured UI components, that should be accessed via the browser, as well.
