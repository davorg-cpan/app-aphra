FROM perl:5.40-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      pandoc \
      build-essential \
      cpanminus \
      libtidy-dev \
      libxml++2.6-dev \
      libhtml-tidy-perl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies first (Docker cache optimisation)
COPY cpanfile* Makefile.PL ./
RUN cpanm -n App::HTTPThis \
 && cpanm -n --installdeps .

# Copy application source
COPY . .

# Install Aphra itself
RUN cpanm -n .

WORKDIR /work

ENTRYPOINT ["aphra"]
CMD ["--help"]

