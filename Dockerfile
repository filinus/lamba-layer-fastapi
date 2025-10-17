ARG ARCH=x86_64

FROM amazon/aws-lambda-python:latest-${ARCH}

RUN echo "Building for architecture: ${ARCH}"

RUN dnf -y --nodocs --noplugins install zip && dnf clean all && rm -rf /var/cache/dnf

WORKDIR /app

COPY requirements.txt .

RUN PLATFORM_TAG=$([ "${ARCH}" = "arm64" ] && echo "manylinux2014_aarch64" || echo "manylinux2014_x86_64") && \
    echo "Using platform tag: ${PLATFORM_TAG}" && \
    pip install \
      --platform ${PLATFORM_TAG} \
      --implementation cp \
      --only-binary=:all: \
      --no-cache-dir \
      -r requirements.txt \
      -t /opt/python/

RUN cd /opt/python \
    && python -m compileall -o 2 -b . \
    && P=__pycache__ \
    && rm -rf $P */$P */*/$P */*/*/$P */*/*/*/$P */*/*/*/*/$P \
    && rm -rf */_tests \
    && rm -rf */experimental \
    && rm -rf */deprecated \
    && rm -rf bin \
    && rm -rf *.dist-info

RUN cd /opt && zip -r6 /app/layer.zip . && unzip -l /app/layer.zip