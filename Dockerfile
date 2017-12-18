FROM ubuntu:16.04

# Install needed things
RUN apt update -y
RUN apt install gcc git net-tools libssl-dev libprotobuf-c0-dev protobuf-c-compiler dh-autoreconf pkg-config libevent-dev libxml2 libxml2-dev libjson-c-dev haveged gnupg wget -y

# Compile FSTRM
RUN git clone https://github.com/farsightsec/fstrm.git /tmp/fstrm
RUN cd /tmp/fstrm && ./autogen.sh && cd /tmp/fstrm && ./configure && cd /tmp/fstrm && make && cd /tmp/fstrm && make install
RUN ldconfig

# Add named user and make directories
RUN useradd named -u 88
RUN mkdir /var/cache/bind /var/named /var/run/named /var/log/named

# Copy named config
COPY conf/bind/bind9.default /etc/default/bind9

# Download root.servers hints
RUN wget http://www.internic.net/domain/named.root -O /var/named/root.servers

# Download, compile, install BIND 9
RUN wget https://ftp.isc.org/isc/bind9/9.11.1/bind-9.11.1.tar.gz -O /tmp/bind-9.11.1.tar.gz
RUN cd /tmp && tar -xvzf bind-9.11.1.tar.gz
RUN cd /tmp/bind-9.11.1 && ./configure --disable-linux-caps --enable-dnstap --with-openssl --enable-threads --with-libxml2 --with-json --sysconfdir /etc/bind
RUN cd /tmp/bind-9.11.1 && make
RUN cd /tmp/bind-9.11.1 && make install

# Copy named.conf
COPY conf/bind/named.conf /etc/bind/named.conf

# Generate conf and key
RUN rndc-confgen -r /dev/urandom > /etc/bind/rndc.conf

EXPOSE 53/udp

# Start named
CMD ["/usr/local/sbin/named", "-f"]
