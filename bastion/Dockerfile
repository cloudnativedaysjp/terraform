FROM public.ecr.aws/amazonlinux/amazonlinux:2023
COPY ./check_login.sh .
RUN chmod 700 check_login.sh

RUN yum update -y && \
    yum install -y procps

    ENTRYPOINT ["./check_login.sh"]

