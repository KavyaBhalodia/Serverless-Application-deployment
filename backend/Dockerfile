FROM public.ecr.aws/lambda/python:3.8
COPY lambda_function.py .
COPY custom_encoder.py .
RUN pip install boto3
CMD ["lambda_function.lambda_handler"]

