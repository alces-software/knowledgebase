# Creating an Azure image

## Prerequisites

* A Libvirt master with the standard Alces setup
* Azure credentials configured on the machine, the command-line utility must be installed
* `qemu-img` version 2.9.0 or above available as a binary in `/opt/vm` (or change the pathname in the script)

## Creating an image

* Run the `create` script, this will build an Azure ready image and place it in the `/opt/vm` directory. The `create` script accepts some basic options, including customizing the name of the image.

## Uploading the image

* Run the `make-azure-image` script, with the full image path as the only argument, e.g.

```bash
./make-azure-image /opt/vm/my-image-1234.qcow2
```

This will upload the image for use on Azure. You can now create a virtual machine from the created image.
