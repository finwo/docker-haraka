# See http://phusion.github.io/baseimage-docker/
FROM phusion/baseimage:master

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q install python-software-properties g++ make git curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | setuser root bash -
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q install nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Optional, useful for development
# See https://github.com/phusion/baseimage-docker#login_ssh
#RUN rm -f /etc/service/sshd/down
#RUN /usr/sbin/enable_insecure_key

# Install Haraka
RUN npm install -g Haraka --unsafe
RUN haraka -i /usr/local/haraka
ADD ./config/host_list /usr/local/haraka/config/host_list
ADD ./config/plugins /usr/local/haraka/config/plugins
RUN cd /usr/local/haraka && npm install

# Create haraka runit service
RUN mkdir /etc/service/haraka
ADD haraka.sh /etc/service/haraka/run

EXPOSE 25

# Start the init daemon - runit will launch the Haraka process
CMD ["/sbin/my_init"]
