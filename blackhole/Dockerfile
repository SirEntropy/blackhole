FROM python:3.12

ENV POETRY_VERSION=1.7

RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /app

RUN echo "Current directory: $(pwd)"
RUN ls -la

COPY pyproject.toml ./
COPY poetry.lock ./
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

COPY . .

EXPOSE 8000

ENV FLASK_ENV=production
CMD ["poetry", "run", "python", "app.py"]