# =========================================================
# IMPORTS
# =========================================================

import os
import csv
import io
import re
import boto3
import snowflake.connector
from dotenv import load_dotenv


# =========================================================
# LOAD ENVIRONMENT VARIABLES
# =========================================================

load_dotenv()

SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")
SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_WAREHOUSE = os.getenv("SNOWFLAKE_WAREHOUSE")
SNOWFLAKE_DATABASE = os.getenv("SNOWFLAKE_DATABASE")
SNOWFLAKE_SCHEMA = os.getenv("SNOWFLAKE_SCHEMA")
SNOWFLAKE_ROLE = os.getenv("SNOWFLAKE_ROLE")

S3_BUCKET = os.getenv("S3_BUCKET")
S3_PREFIX = os.getenv("S3_PREFIX")


# =========================================================
# SNOWFLAKE CONNECTION
# =========================================================

def get_snowflake_connection():
    return snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        warehouse=SNOWFLAKE_WAREHOUSE,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA,
        role=SNOWFLAKE_ROLE,
    )


# =========================================================
# AWS S3 CLIENT
# =========================================================

def get_s3_client():
    return boto3.client("s3")


# =========================================================
# UTILS
# =========================================================

def clean_column_name(column_name: str) -> str:
    column_name = column_name.strip().lower()
    column_name = re.sub(r"[^a-z0-9_]", "_", column_name)
    column_name = re.sub(r"_+", "_", column_name)
    return column_name.strip("_")


def csv_file_to_table_name(file_key: str) -> str:
    file_name = file_key.split("/")[-1]
    table_name = file_name.replace(".csv", "")
    table_name = table_name.replace("olist_", "")
    table_name = table_name.replace("_dataset", "")
    return f"raw_{table_name}"


# =========================================================
# LIST CSV FILES FROM S3
# =========================================================

def list_csv_files_from_s3(s3_client):
    response = s3_client.list_objects_v2(
        Bucket=S3_BUCKET,
        Prefix=S3_PREFIX,
    )

    csv_files = []

    for item in response.get("Contents", []):
        file_key = item["Key"]

        if file_key.endswith(".csv"):
            csv_files.append(file_key)

    return csv_files


# =========================================================
# READ CSV HEADERS FROM S3
# =========================================================

def get_csv_headers_from_s3(s3_client, file_key: str):
    response = s3_client.get_object(
        Bucket=S3_BUCKET,
        Key=file_key,
    )

    file_content = response["Body"].read().decode("utf-8")
    reader = csv.reader(io.StringIO(file_content))

    headers = next(reader)
    return [clean_column_name(header) for header in headers]


# =========================================================
# CREATE FILE FORMAT
# =========================================================

def create_file_format(cursor):
    cursor.execute("""
        CREATE OR REPLACE FILE FORMAT csv_file_format
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
        ENCODING = 'UTF8';
    """)


# =========================================================
# CREATE S3 STAGE
# =========================================================

def create_s3_stage(cursor):
    aws_access_key = os.getenv("AWS_ACCESS_KEY_ID")
    aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")

    cursor.execute(f"""
        CREATE OR REPLACE STAGE olist_s3_stage
        URL = 's3://{S3_BUCKET}/{S3_PREFIX}'
        CREDENTIALS = (
            AWS_KEY_ID = '{aws_access_key}'
            AWS_SECRET_KEY = '{aws_secret_key}'
        )
        FILE_FORMAT = csv_file_format;
    """)


# =========================================================
# CREATE RAW TABLE DYNAMICALLY
# =========================================================

def create_raw_table(cursor, table_name: str, headers: list[str]):
    columns_sql = ",\n".join(
        [f"{column} STRING" for column in headers]
    )

    create_table_sql = f"""
        CREATE OR REPLACE TABLE {table_name} (
            {columns_sql}
        );
    """

    cursor.execute(create_table_sql)


# =========================================================
# LOAD DATA WITH COPY INTO
# =========================================================

def copy_csv_into_table(cursor, table_name: str, file_key: str):
    file_name = file_key.split("/")[-1]

    copy_sql = f"""
        COPY INTO {table_name}
        FROM @olist_s3_stage/{file_name}
        FILE_FORMAT = csv_file_format
        ON_ERROR = 'CONTINUE';
    """

    cursor.execute(copy_sql)


# =========================================================
# MAIN PIPELINE
# =========================================================

def main():
    s3_client = get_s3_client()
    csv_files = list_csv_files_from_s3(s3_client)

    if not csv_files:
        print("No CSV files found in S3.")
        return

    connection = get_snowflake_connection()
    cursor = connection.cursor()

    try:
        print("Creating Snowflake file format...")
        create_file_format(cursor)

        print("Creating Snowflake S3 stage...")
        create_s3_stage(cursor)

        for file_key in csv_files:
            table_name = csv_file_to_table_name(file_key)

            print(f"\nProcessing file: {file_key}")
            print(f"Target table: {table_name}")

            headers = get_csv_headers_from_s3(s3_client, file_key)

            print("Creating RAW table...")
            create_raw_table(cursor, table_name, headers)

            print("Loading data into Snowflake...")
            copy_csv_into_table(cursor, table_name, file_key)

            print(f"Done: {table_name}")

    finally:
        cursor.close()
        connection.close()


# =========================================================
# ENTRY POINT
# =========================================================

if __name__ == "__main__":
    main()