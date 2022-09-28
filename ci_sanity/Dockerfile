FROM ALPINE_VERSION

RUN apk add --no-cache bash git curl make grep sed \
      python3 py3-pip py3-cffi py3-cryptography \
    && pip3 install --no-cache-dir python-dotenv jinja2 rich python-gitlab build twine wheel
