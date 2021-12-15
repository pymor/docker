ARG BASE
ARG CONSTRAINTS_IMAGE

# cannot user arg directly in COPY --from
FROM ${CONSTRAINTS_IMAGE} as constraints
FROM ${BASE}

COPY --from=constraints /requirements/* /requirements/
COPY check_import.py /usr/local/bin/

RUN chmod 777 /cache \
  && cp /requirements/constraints.txt /requirements/stable_constraints.txt \
  && python3 -m pip install check_reqs
