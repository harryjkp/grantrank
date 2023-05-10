# Define custom function directory
ARG FUNCTION_DIR="./"

FROM python:3.10 as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}
COPY requirements.txt ${FUNCTION_DIR}/requirements.txt
COPY lambda_function.py ${FUNCTION_DIR}/lambda_function.py

WORKDIR ${FUNCTION_DIR}

RUN pip install -r requirements.txt --target ${FUNCTION_DIR}

# Install the function's dependencies
RUN pip install \
    --target ${FUNCTION_DIR} \
        awslambdaric

FROM python:3.10 as runtime-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

RUN pip install awscli

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}


# ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
# CMD [ "lambda_function.lambda_handler" ]

FROM runtime-image as test-image

RUN mkdir -p /.aws-lambda-rie && curl -Lo /.aws-lambda-rie/aws-lambda-rie \
https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie \
&& chmod +x /.aws-lambda-rie/aws-lambda-rie  
ENTRYPOINT [ "/.aws-lambda-rie/aws-lambda-rie","/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "lambda_function.lambda_handler" ]




# FROM python:3.10 as environment
# RUN pip install -U --force-reinstall --upgrade virtualenv virtualenvwrapper
# # Create a python virtual environment
# RUN python -m venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"
# RUN pip install -U --force-reinstall --upgrade virtualenv virtualenvwrapper

# FROM python:3.10 as test

# COPY --from=environment /opt/venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"

# RUN pip install numpy

# # Install dependencies
# COPY requirements.txt .
# RUN pip install -r requirements.txt

# FROM public.ecr.aws/lambda/python:3.8

# RUN pip install -U --force-reinstall --upgrade virtualenv virtualenvwrapper

# COPY --from=test /opt/venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"

# RUN pip install numpy # #15 0.241 /bin/sh: /opt/venv/bin/pip: /opt/venv/bin/python: bad interpreter: No such file or directory.

# COPY lambda_function.py ./

# CMD ["lambda_function.lambda_handler"]

