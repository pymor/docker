ARG BASE
FROM ${BASE}

COPY --from=pymor/constraints_pyPYVER:VERTAG /requirements/* /requirements/

RUN chmod 777 /cache \
  && cp /requirements/constraints.txt /requirements/stable_constraints.txt
