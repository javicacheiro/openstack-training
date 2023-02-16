FROM rockylinux:8
MAINTAINER "Javier Cacheiro" <javier.cacheiro.lopez@cesga.es>

ENV container docker
ENV REFRESHED_AT 2022-02-16

# Update packages and install opensearch
RUN dnf -y update \
 && curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/opensearch-2.x.repo -o /etc/yum.repos.d/opensearch-2.x.repo \
 && dnf install -y 'opensearch-2.5.0' \
 && dnf clean all

COPY opensearch.yml /etc/opensearch/opensearch.yml

USER opensearch
WORKDIR /usr/share/opensearch

VOLUME /data

EXPOSE 9200

CMD ["/usr/share/opensearch/bin/opensearch"]
