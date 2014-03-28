deployment
=============

A repository that can be embedded as a submodule that helps with various kinds of deployment

Setup
------
(from the root of your other repository you wish to embed this in)
`git subtree add --prefix deployment https://github.com/jjl/deployment.git master --squash`

To update is:

`git subtree pull --prefix deployment https://github.com/jjl/deployment.git master --squash`

Usage
------
(From this directory)

For python:
`make bootstrap-python`

For npm:
`make npm-mirror-deps`

Caveats
---------

Currently, we expect you to list virtualenv in your requirements.txt
