# Running a Python 3.10 development environment
In this lab we will be running a container so we can use the new `match case` statement introduced in python 3.10:
- [Structural Pattern Matching](https://peps.python.org/pep-0622/)
- [Structural Pattern Matching Usage](https://henryiii.github.io/level-up-your-python/notebooks/2.8%20Pattern%20Matching.html)

If we look into the python version of the host we will see that it has:
```
[cesgaxuser@openstack-cli ~]$ python3 --version
Python 3.6.8
```

If we try to run the sample `python_match.py` script we will get:
```
[cesgaxuser@openstack-cli ~]$ python3 python_match.py
  File "python_match.py", line 12
    match circle:
               ^
SyntaxError: invalid syntax
```

So we are going to set up a python 3.10 development environment using docker.

First we will create a directory for our scripts that we will share with the container:
```
mkdir scripts
```

Run docker:
```
docker run -v ./scripts:/tmp/scripts -ti python:3.10-alpine /bin/sh
```

Now we can move to the scripts directory in the docker container:
```
cd /tmp/scripts
```

And in the host we can place the `python_match.py` sample script inside the `scripts` host directory:
```
cp python_match.py scripts
```

Now we will se the `python_match.py` inside the container:
```
ls -l
```

And we can run it:
```
python3 python_match.py
```

Changes in the `scripts` host directory are automatically seen in the container and viceversa.
