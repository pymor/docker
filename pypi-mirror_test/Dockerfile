ARG BASE
ARG CONSTRAINTS_IMAGE

# cannot user arg directly in COPY --from
FROM ${CONSTRAINTS_IMAGE} as constraints
FROM ${BASE}

COPY --from=constraints /requirements/* /requirements/

RUN chmod 777 /cache \
  && cp /requirements/constraints.txt /requirements/stable_constraints.txt
