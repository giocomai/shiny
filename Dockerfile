FROM r-base:latest

MAINTAINER Giorgio Comai "giorgiocomai@gmail.com"

RUN apt-get update && apt-get install -y -t unstable \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev

# install packages required by `castarter`
RUN apt-get update && apt-get install -y \
	r-cran-rjava \
	r-cran-xml \
	libssl-dev \
	r-cran-curl

# Download and install shiny server
RUN wget https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/
    
# Install castarter packages in R
RUN R -e "install.packages(c('ggplot2', 'stringi', 'mgcv', 'devtools'), repos='http://cran.rstudio.com/'); devtools::install_github('giocomai/castarter')"

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
