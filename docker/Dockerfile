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
RUN cpanm -n App::HTTPThis~0.11.1

# Copy application source
COPY . .
RUN cpanm -n --installdeps .

# Install Aphra itself
RUN cpanm -n .

WORKDIR /work

ENTRYPOINT ["aphra"]
CMD ["--help"]

