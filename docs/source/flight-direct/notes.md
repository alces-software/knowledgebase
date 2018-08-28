These are additional notes that supplement the now read only quip notes
the header have been include to allow for the notes to be merged at a latter
date.

# Anvil Setup:
DOC NOTE: The above heading is missing in the quip doc. Sorry

## Step 1: Install Flight Direct

.. STUFF ..

## Step 4: Install Anvil
.. GUIDE ..

### NOTE: NetTimeOut error
The library that downloads the packages has an automatic timeout which 
sometimes fails. ATM this error is not being caught and will cause the
snapshot to fail. To manually restart the snapshot please run:

```
# Switch to root
sudo su -

# Move to the anvil dir inside the Flight environment
flight bash 
cd /opt/anvil

# Stop the anvil server (if it is running) and drop the database
systemctl stop anvil
rake db:drop

# Re-preform the Snapshot
rake packages:snapshot

# Start the server
systemctl start anvil
```

