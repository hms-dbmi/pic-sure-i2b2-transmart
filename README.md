# pic-sure-i2b2-transmart
Research infrastructure powered by PIC-SURE and i2b2/tranSMART. This serves as a reference implementation 
for use in production environments where the databases reside off the application server.

All containers are based on public images. To configure the environment, follow the instructions provided in the [config/](config/) directory.

# Installation

On a new server, or docker machine, run the following commands to install and start up the whole stack. 

It requires privileges to the GitHub repo and to be able run `docker` commands on the machine itself.

```

cd /var/tmp
rm -fR pic-sure-i2b2-transmart
git clone https://github.com/hms-dbmi/pic-sure-i2b2-transmart.git
cd pic-sure-i2b2-transmart/

docker-compose down
docker-compose pull
docker-compose build
docker-compose up -d

```

If all commands run successfully, navigate your desktop browser to the public IP address of the host machine.

