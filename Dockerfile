FROM mongo:3.4
ADD init-mongo.sh /tmp/init-mongo.sh
CMD /tmp/init-mongo.sh
