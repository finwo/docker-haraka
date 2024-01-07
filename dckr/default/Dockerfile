FROM node:alpine

# Install Haraka
RUN npm install -g Haraka@${PATCH} --unsafe
RUN haraka -i /opt/haraka
ADD ./config/host_list /opt/haraka/config/host_list
ADD ./config/plugins   /opt/haraka/config/plugins
RUN cd /opt/haraka && npm install

ADD entrypoint.sh /opt/haraka/entrypoint.sh

EXPOSE 25

CMD ["/opt/haraka/entrypoint.sh"]
