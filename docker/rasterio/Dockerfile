FROM remotepixel/amazonlinux-gdal:2.4.0-light

WORKDIR /var/task/python
ENV WORKDIR /var/task/python

RUN mkdir -p $WORKDIR
COPY docker/rasterio/.lambdaignore /var/task
RUN CFLAGS="--std=c99" pip3 install rasterio[s3]~=1.0.28 shapely~=1.6.4.post2 pyproj~=2.1.3 --no-binary numpy,rasterio,shapely -t $WORKDIR -U

RUN python -m compileall .
RUN find -type f -name '*.pyc' | while read f; do n=$(echo $f | sed 's/__pycache__\///' | sed 's/.cpython-36//'); cp $f $n; done;
RUN find -type d -a -name '__pycache__' -print0 | xargs -0 rm -rf
RUN find -type f -a -name '*.py' -print0 | xargs -0 rm -f

RUN cd /var/task && \
    cat .lambdaignore | xargs zip -9qyr /var/task/layer.zip python lib/*.so* share -x
#RUN cd /var/task; zip -r9q --symlinks /var/task/layer.zip
#RUN cd /var/task; zip -r9q /var/task/layer.zip share

CMD ["/bin/bash"]