FROM rocker/shiny:4.1.3

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libglpk-dev \
    libxml2-dev

RUN install2.r --error --skipinstalled \
    ggplot2 \
    ggrepel \
    dplyr


COPY app /srv/shiny-server/ispi

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]