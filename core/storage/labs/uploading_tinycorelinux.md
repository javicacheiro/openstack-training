# Installing Tiny Core Linux
Installing the Tiny Core Linux distro from a iso:
```
# Download
curl -O http://www.tinycorelinux.net/13.x/x86/release/TinyCore-current.iso
```

Upload to openstack (create image):
```
openstack image create --private --disk-format iso --container-format bare --file TinyCore-current.iso tinycorelinux-13.1
```
we can also do it from Horizon.

Boot from the new image. The easiest is to use Horizon so we have a grahical user interface during installation:
- Compute > Images: tinycorelinux-13.1
- Launch
- Name it `<username>-tcl` and select flavor m1.1c2m and the rest as usual

We can see the graphical console in:
- Compute > Instances
- Select your instace
- Go to the "Console" tab

Then with the final volume we will upload it as an image.
