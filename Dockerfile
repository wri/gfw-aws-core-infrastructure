FROM hashicorp/terraform:0.13.3

RUN \
    apk add --no-cache \
        bash \
        make \
        python3 \
        zip \
    && pip3 install awscli
