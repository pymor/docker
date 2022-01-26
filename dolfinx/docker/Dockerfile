# EXPERIMENTAL_SYNTAX

FROM pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOLFINX_VERSION="main"
WORKDIR /tmp

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/

COPY install.bash /tmp
RUN MOUNT_CACHE \
  apt update \
  && ${APTINSTALL} libptscotch-dev \
  && bash /tmp/install.bash "MAKE_ARGS"
# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN apt-get update && apt-get -y install xvfb
# COPY demo_auto-adaptive_poisson.py /tmp/poisson_test/
# RUN /bin/bash -l -c "cd /tmp/poisson_test && \
#     time xvfb-run python demo_auto-adaptive_poisson.py && \
#     rm -r /tmp/poisson_test"

RUN MOUNT_CACHE \
  python -c "import dolfinx" \
  && rm -rf /usr/local/man
