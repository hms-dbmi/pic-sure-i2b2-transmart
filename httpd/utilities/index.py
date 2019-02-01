import os, sys
from string import Template

# ${ENVIRONMENT} ${CONFIGURATOR_TEMPLATE_DIR} ${CONFIGURATOR_OUTPUT_DIR} ${FILENAME}

env = sys.argv[1]
template_dir = sys.argv[2]
filepath = sys.argv[3]

tmpltfile = open(template_dir+filepath)
tmplt = Template( tmpltfile.read() )

envvars = {}
# Read in all the values from the `VAULT` file, if there is one
if (os.path.exists(template_dir+'/'+env+'.txt')) :
    f = open(template_dir+'/'+env+'.txt', 'r')
    for line in f:
        listedline = line.strip().split('=') # split around the = sign
        if len(listedline) > 1: # we have the = sign in there
            envvars[listedline[0]] = listedline[1]


# Add all the environment variables to the available values
allvalues = envvars.update(os.environ)

#do the substitution
result = tmplt.substitute(envvars)
print result
