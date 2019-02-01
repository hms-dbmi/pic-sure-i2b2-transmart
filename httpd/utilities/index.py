import os, sys
from string import Template

#open the file
tmpltfile = open( 'index.template' )
#read it
tmplt = Template( tmpltfile.read() )

#document data
f = open('index.txt', 'r')
envvars = {}
for line in f:
    listedline = line.strip().split('=') # split around the = sign
    if len(listedline) > 1: # we have the = sign in there
        envvars[listedline[0]] = listedline[1]

allvalues = envvars.update(os.environ)
#do the substitution
result = tmplt.substitute(envvars)
print result
