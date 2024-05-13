FROM python:3.12

ENV POETRY_VERSION=1.7

RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

COPY . .

EXPOSE 8000

ENV FLASK_ENV=production
CMD ["poetry", "run", "python", "app.py"]
