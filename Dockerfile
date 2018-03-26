# Starting from maven image
FROM maven:3-jdk-8

# Run as root
USER root

# Create Distelli user
RUN useradd -ms /bin/bash distelli

# Set /home/distelli as the working directory
WORKDIR /home/distelli

# Install prerequisites. This provides me with the essential tools for building with.
# Note. You don't need git or mercurial.
RUN apt-get update -y \
    && apt-get -y install build-essential checkinstall git mercurial \
    && apt-get -y install libssl-dev openssh-client openssh-server \
    && apt-get -y install curl apt-transport-https ca-certificates \
    && apt-get -y install software-properties-common

# Update the .ssh/known_hosts file:
RUN sh -c "ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts"

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://pipelines.puppet.com/download/client | sh

# Install Docker
# Note. This is only necessary if you plan on building Docker images
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" \
  && apt-get update -y \
   && apt-get -y install docker-ce

#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
#    &&  sh -c "echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list" \
#    &&  apt-get update -y \
#    &&  apt-get purge -y lxc-docker \
#    &&  apt-get -y install docker-engine \
#    &&  sh -c 'curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose' \
#    &&  chmod +x /usr/local/bin/docker-compose \
#    &&  docker -v

# Setup a volume for writing Docker layers/images
VOLUME /var/lib/docker

# Install gosu
ENV GOSU_VERSION 1.9
RUN  curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
     && sudo chmod +x /bin/gosu

# An informative file I like to put on my shared images
RUN  sh -c "echo 'Puppet Pipelines Build Image maintained by Joel Morris joel.a.morris@gmail.com' >> /puppet_pipelines_build_image.info"

# The following entry point is not necessary
CMD ["/bin/bash"]
