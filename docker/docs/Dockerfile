FROM python:3.9-slim

WORKDIR /docs

# Install MkDocs and a nice theme
RUN pip install --no-cache-dir mkdocs mkdocs-material

# Create a basic mkdocs configuration if it doesn't exist
RUN echo 'site_name: SaaS Pipeline Documentation\n\
theme:\n\
  name: material\n\
  palette:\n\
    primary: indigo\n\
    accent: indigo\n\
  features:\n\
    - navigation.instant\n\
    - navigation.tracking\n\
    - navigation.expand\n\
    - navigation.indexes\n\
    - content.code.annotate\n\
nav:\n\
  - Home: index.md\n\
  - MVP Architecture: mvp-architecture.md\n\
  - Enterprise Architecture: enterprise-architecture.md\n\
' > /tmp/mkdocs.yml

# Create a default index page if it doesn't exist
RUN mkdir -p /tmp/docs && echo '# SaaS Pipeline Documentation\n\
\n\
## Overview\n\
\n\
This documentation covers the architecture and components of the SaaS Pipeline system.\n\
\n\
## Contents\n\
\n\
- [MVP Architecture](mvp-architecture.md) - The simplified implementation for our MVP\n\
- [Enterprise Architecture](enterprise-architecture.md) - The ultimate production architecture\n\
' > /tmp/docs/index.md

# Move default files if not exist in the mounted volume (will be overwritten by the mount)
CMD if [ ! -f /docs/mkdocs.yml ]; then cp /tmp/mkdocs.yml /docs/; fi && \
    if [ ! -d /docs/docs ]; then mkdir -p /docs/docs; fi && \
    if [ ! -f /docs/docs/index.md ]; then cp /tmp/docs/index.md /docs/docs/; fi && \
    cp /docs/*.md /docs/docs/ 2>/dev/null || true && \
    cd /docs && mkdocs serve -a 0.0.0.0:8000 