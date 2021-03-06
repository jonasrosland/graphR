FROM centos:7

RUN yum -y update && yum -y install \
	epel-release \
	java-1.8.0-openjdk \
	java-1.8.0-openjdk-devel \
	libapreq2-devel \
	libcurl-devel \
	libpng-devel \
	libtiff-devel \
	libjpeg-turbo-devel \
	wget \
	yum-utils && \
	yum clean all

RUN yum -y update && yum -y install \
	R

RUN	R -e "install.packages('shiny', repos='http://cran.rstudio.com/')" && \
	wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.3.838-rh5-x86_64.rpm && \
	yum -y install --nogpgcheck shiny-server-1.5.3.838-rh5-x86_64.rpm && \
	R -e "install.packages(c('broom', 'digest', 'dplyr', 'flexdashboard', 'forcats', 'GGally', 'ggplot2', 'maps', 'markdown', 'network', 'png', 'RColorBrewer', 'readxl', 'reshape2', 'rmarkdown', 'scales', 'shinydashboard', 'shinyjs', 'sna', 'statnet.common', 'tibble'), repos='https://cran.rstudio.com/')"
	
COPY ./graphr /srv/shiny-server/graphr
COPY ./shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY cleaning_job.sh /cleaning_job.sh
COPY crontab_entry.txt /etc/cron.d/cleaning-job

RUN chmod +x /cleaning_job.sh && chmod 0644 /etc/cron.d/cleaning-job && touch /var/log/cron.log

EXPOSE 3838

CMD [ "/bin/sh", "-c", "/usr/sbin/crond & /usr/bin/shiny-server" ]
