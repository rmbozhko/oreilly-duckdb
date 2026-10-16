FROM python:3.12-slim

# Copy uv binary from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Environment settings for uv
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Copy project specification files
COPY pyproject.toml /app/

# Lock and install dependencies
RUN uv lock && uv sync

# Copy the rest of the project
COPY . /app

# Register the specific "duckdb" kernel using uv run
RUN uv run python -m ipykernel install --user --name duckdb --display-name "DuckDB Kernel"

EXPOSE 8888

# Launch Jupyter via uv run
CMD ["uv", "run", "jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
