FROM amazon/aws-lambda-python

#RUN ls -la /var/lang/lib/python3.13/site-packages

RUN dnf -y --nodocs --noplugins install zip && dnf clean all && rm -rf /var/cache/dnf

WORKDIR /app

COPY requirements.txt .

RUN pip install \
    --platform manylinux2014_x86_64 \
    --target=package \
    --implementation cp \
    --only-binary=:all: \
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