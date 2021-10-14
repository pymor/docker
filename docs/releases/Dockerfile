FROM docker.io/pymor/demo:0.4 as demo04
COPY build_docs.bash /home/pymor/
RUN MOUNT_CACHE /home/pymor/build_docs.bash 0.4.x

FROM docker.io/pymor/demo:0.5 as demo05
COPY build_docs.bash /home/pymor/
RUN MOUNT_CACHE /home/pymor/build_docs.bash 0.5.x

FROM docker.io/pymor/demo:2019.2 as demo2019.2
COPY build_docs.bash /home/pymor/
USER root
RUN pip install pymor-nb2plots==0.7 PySide2==5.15.0 && \
  apt update && apt install -y libqt5widgets5 libqt5gui5
USER pymor
RUN MOUNT_CACHE /home/pymor/build_docs.bash 2019.2.x

FROM docker.io/pymor/demo:2020.1 as demo2020.1
USER root
RUN pip install sphinx_material slycot
USER pymor
COPY build_docs.bash /home/pymor/
RUN MOUNT_CACHE /home/pymor/build_docs.bash 2020.1.x

FROM docker.io/pymor/demo:2020.2 as demo2020.2
USER pymor
COPY build_docs.bash /home/pymor/
RUN MOUNT_CACHE /home/pymor/build_docs.bash 2020.2.x

FROM alpine:3.12

COPY --from=demo04 /home/pymor/docs/ /docs/
COPY --from=demo05 /home/pymor/docs/ /docs/
COPY --from=demo2019.2 /home/pymor/docs/ /docs/
COPY --from=demo2020.1 /home/pymor/docs/ /docs/

RUN ls -hl /docs/
