FROM centos:centos7

MAINTAINER Nigel Gibbs <nigel@gibbsoft.com>

ENV JAVA_VERSION 1.8.0
ENV ANSIBLE_VERSION 2.0.2.0
ENV LIQUIBASE_VERSION 3.4.2
ENV PGJDBC_VERSION 9.4.1208.jre7
ENV TERRAFORM_VERSION 0.6.16
ENV JMETER_VERSION 3.0
ENV PATH /terraform:$PATH
ENV MIN_SETUPTOOLS_VERSION 11.3

# Install a few RPMs
RUN echo "===> Adding epel, java, ruby, pip, etc" && \
    yum update -y && \
    yum group install -y "Development Tools" && \
    yum install -y epel-release && \
    yum install -y wget bc openssl sudo unzip graphviz git perl jq \
      java-${JAVA_VERSION}-openjdk java-${JAVA_VERSION}-openjdk-devel \
      maven libffi-devel which ruby ruby-devel rubygem-bundler \
      python-pip python-devel zlib-devel openssl-devel

# Install Ansible pre-reqs
RUN echo "===> Adding ansible pre-reqs" && \
    pip install --upgrade "setuptools>=${MIN_SETUPTOOLS_VERSION}"

# Install Ansible
RUN echo "===> Adding ansible ${ANSIBLE_VERSION}" && \
    pip install ansible==${ANSIBLE_VERSION}

# Download liquibase
RUN echo "===> Adding liquibase ${LIQUIBASE_VERSION}" && \
    wget -P /tmp https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.4.2/liquibase-${LIQUIBASE_VERSION}-bin.tar.gz && \
    mkdir -p /opt/liquibase && \
    tar -xzf /tmp/liquibase-3.4.2-bin.tar.gz -C /opt/liquibase && \
    chmod +x /opt/liquibase/liquibase && \
    ln -s /opt/liquibase/liquibase /usr/local/bin/

# Add JDBC driver
RUN echo "===> Adding postgres jdbc driver ${PGJDBC_VERSION}" && \
    mkdir -p /opt/jdbc_drivers && \
    wget -P /tmp https://jdbc.postgresql.org/download/postgresql-${PGJDBC_VERSION}.jar && \
    mv /tmp/postgresql-${PGJDBC_VERSION}.jar /opt/jdbc_drivers/ && \
    ln -s /opt/jdbc_drivers/postgresql-${PGJDBC_VERSION}.jar /opt/liquibase/lib

# Add jMeter
RUN echo "===> Adding jMeter ${JMETER_VERSION}" && \
    wget http://mirror.vorboss.net/apache/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar zxvf apache-jmeter-${JMETER_VERSION}.tgz -C /opt/ && \
    ln -s /opt/apache-jmeter-${JMETER_VERSION} /opt/jmeter && \
    ln -s /opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter /usr/local/bin/

# Add terraform
RUN echo "===> Adding terraform ${TERRAFORM_VERSION}" && \
    wget -P /tmp "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

# Add Gems
RUN echo "===> Adding gems" && \
    gem install liquid diplomat fog json fpm jekyll awscli \
      rspec mechanize cucumber git coderay rake ruby-jmeter \
      rubocop english

# Clean up
RUN echo "===> Cleaning up" && \
    rm -rf /tmp/* && \
    yum upgrade -y && \
    yum clean all # && yum group remove -y "Development Tools"

WORKDIR /

# default command: display Ansible version
CMD [ "ansible", "-version" ]
