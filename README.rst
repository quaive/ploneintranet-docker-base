ploneintranet-base
==================

This builds a docker image suitable as a base image for ploneintranet projects.
It installs all system dependencies and primes buildout caches in /var/tmp.

The intented use case is, as a base image for gitlab-ci runners, which will
benefit from the caches provided in this image to accelerate test builds.

This image does not actually install or run ploneintranet.
While it runs a buildout, the results are discarded, only the caches are kept.
This image does not require access to the private quaive/ploneintranet repo.

Usage
-----

Use the image as a base for your project image's Dockerfile::

  FROM quaive/ploneintranet-base:latest

gitlab-ci runner
----------------

When registering a gitlab-ci runner, use quaive/ploneintranet-base as the
docker image for test executors.

Start a runner::

  docker run -d --name gitlab-runner-01 --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /srv/gitlab-runner-01/config:/etc/gitlab-runner \
    gitlab/gitlab-runner:latest

Register the runner::

  docker exec -it gitlab-runner-01 gitlab-runner register

  Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/ci )
  https://gitlab.com/ci
  Please enter the gitlab-ci token for this runner
  xxx
  Please enter the gitlab-ci description for this runner
  my-runner-01
  INFO[0034] fcf5c619 Registering runner... succeeded
  Please enter the executor: shell, docker, docker-ssh, ssh?
  docker
  Please enter the Docker image (eg. ruby:2.1):
  quaive/ploneintranet:latest
  INFO[0037] Runner registered successfully.


You can set up multiple runners by repeating the commands above,
replacing "runner-01" with "runner-02" etc.

You can find the gitlab-ci token "xxx" in your gitlab.com project under
"Settings" > "Runners".

For more info, see the docs at:
https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/blob/master/docs/install/docker.md
