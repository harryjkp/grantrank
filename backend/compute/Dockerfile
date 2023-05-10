# Define custom function directory
ARG FUNCTION_DIR="./"

FROM python:3.10 as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}
COPY requirements.txt ${FUNCTION_DIR}/requirements.txt

WORKDIR ${FUNCTION_DIR}

RUN pip install -r requirements.txt --target ${FUNCTION_DIR}

FROM public.ecr.aws/lambda/python:3.10


COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

COPY lambda_function.py ./

CMD ["lambda_function.lambda_handler"]

