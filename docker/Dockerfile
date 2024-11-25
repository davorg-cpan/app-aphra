FROM perl:latest

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y pandoc && \
    apt-get install -y build-essential && \
    apt-get install -y cpanminus libtidy-dev libxml++2.6-dev libhtml-tidy-perl && \
    cpanm -n App::HTTPThis App::Aphra@0.2.3

