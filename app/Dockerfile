FROM python:3.9-slim

# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser appuser

# copy the requirements file into the image
COPY ./requirements.txt /app/requirements.txt

# switch working directory
WORKDIR /app

# install the dependencies and packages in the requirements file
RUN pip install -r requirements.txt

# copy every content from the local file to the image
COPY . /app

# change ownership of the app directory to the non-root user
RUN chown -R appuser:appuser /app

# switch to the non-root user
USER appuser

# configure the container to run in an executed manner
ENTRYPOINT [ "python" ]

EXPOSE 5000

CMD ["/usr/local/bin/gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
