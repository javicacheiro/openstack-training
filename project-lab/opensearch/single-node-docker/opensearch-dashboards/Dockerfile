FROM rockylinux:8
MAINTAINER "Javier Cacheiro" <javier.cacheiro.lopez@cesga.es>

ENV container docker
ENV REFRESHED_AT 2022-02-16

# Update packages and install opensearch
RUN dnf -y update \
 && curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/opensearch-dashboards-2.x.repo -o /etc/yum.repos.d/opensearch-dashboards-2.x.repo \
 && dnf install -y 'opensearch-dashboards-2.5.0' findutils \
 && dnf clean all

COPY opensearch_dashboards.yml /etc/opensearch-dashboards/opensearch_dashboards.yml
COPY start.sh /start.sh

USER opensearch-dashboards
WORKDIR /usr/share/opensearch-dashboards

EXPOSE 5601

ENV OSD_PATH_CONF "/etc/opensearch-dashboards"
CMD ["/usr/share/opensearch-dashboards/bin/opensearch-dashboards"]
