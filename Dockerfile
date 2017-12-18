FROM ubuntu:16.04

RUN apt update -y
RUN apt install gcc git libssl-dev libprotobuf-c0-dev protobuf-c-compiler dh-autoreconf pkg-config libevent-dev libxml2 libxml2-dev libjson-c-dev haveged gnupg wget -y

RUN git clone https://github.com/farsightsec/fstrm.git -o /tmp/fstrm
RUN cd /tmp/fstrm && ./autogen.sh && ./configure && make && sudo make install
RUN ldconfig

RUN useradd named -u 88
RUN mkdir /var/cache/bind /var/named /var/run/named /var/log/named

COPY conf/bind/named.service /etc/systemd/system/named.service
COPY conf/bind/bind9.default /etc/default/bind9

RUN curl http://www.internic.net/domain/named.root -o /var/named/root.servers

RUN curl https://ftp.isc.org/isc/bind9/9.11.1/bind-9.11.1.tar.gz -o /tmp/bind-9.11.1.tar.gz
RUN cd /tmp && tar -xvzf bind-9.11.1.tar.gz
RUN cd /tmp/bind-9.11.1 && ./configure --enable-dnstap --with-openssl --enable-threads --with-libxml2 --with-json --sysconfdir /etc/bind
