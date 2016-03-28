FROM registry.access.redhat.com/rhel
MAINTAINER Dmitry Ratushnyy <d.ratushnyy@gmail.com>

RUN yum -y update; yum clean all
#install dependencies
RUN yum -y install screen vim iputils redhat-rpm-config gmp-devel postgresql-devel wget openssl-devel openssh-server libsqlite3-devel libldap2-devel libffi-devel git python-setuptools curl ftp automake make autoconfi gcc gcc-c++ libxml2-devel libxslt-devel lib32z1-devel python2.7-devel python-devel libssl-devel libxml2-python libxslt1-devel libsasl2-devel
RUN echo 'root:toor'| chpasswd
#ssh config
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN /usr/bin/ssh-keygen -A

#setup tempest
RUN useradd tempest
RUN echo 'tempest:tempest'| chpasswd
RUN git clone -b proposed  https://github.com/cisco-openstack/tempest.git
RUN easy_install pip
RUN pip install -r /tempest/requirements.txt
RUN pip install -r /tempest/test-requirements.txt
RUN mkdir /etc/tempest
RUN cp /tempest/etc/accounts.yaml.sample  /etc/tempest/accounts.yaml

EXPOSE 22
CMD [ "/usr/sbin/sshd", "-D"]
