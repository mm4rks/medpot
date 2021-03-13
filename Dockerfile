FROM alpine

# Based on Marco Ochse great Glutton / T-Pot template

# Setup apk
RUN apk -U --no-cache add \
                   build-base \
                   git \
                   go \
                   g++

# Setup go, medpot
ENV GOPATH=/opt/go
RUN mkdir -p /opt/go/src
RUN git clone https://github.com/schmalle/medpot.git $GOPATH/src/medpot
RUN go get -d -v github.com/davecgh/go-spew/spew
RUN go get -d -v github.com/go-ini/ini
RUN go get -d -v github.com/mozillazg/request
RUN go get -d -v go.uber.org/zap
RUN cd $GOPATH/src/medpot && go build medpot
RUN cp $GOPATH/src/medpot/medpot /usr/bin/medpot

RUN mkdir -p /var/log/medpot
RUN touch /var/log/medpot/medpot.log
RUN mkdir -p /data/medpot
RUN cd $GOPATH/src/medpot/template && \
    cp ./ews.xml /data/medpot/ && \
    cp ./dummyerror.xml /data/medpot/
RUN cp $GOPATH/src/medpot/dist/etc/ews.cfg /etc/


# Setup user, groups and configs
RUN    addgroup -g 2000 medpot && \
    adduser -S -s /bin/ash -u 2000 -D -g 2000 medpot && \
    mkdir -p /var/log/medpot

# Clean up
RUN    apk del --purge build-base \
                    git \
                    go \
                    g++ && \
    rm -rf /var/cache/apk/* \
           /opt/go \
           /root/dist

# Start medpot
WORKDIR /opt/go/src/medpot
#USER medpot:medpot
CMD exec medpot
