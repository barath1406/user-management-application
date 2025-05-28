import json
import os
import re

import csv
import urllib.parse
import boto3
import pymysql

from datetime import datetime

# Environment variables for RDS connection
RDS_HOST = os.environ.get('DB_HOST')
RDS_USER = os.environ.get('DB_USER')
SECRET_NAME = os.environ.get('SECRET_NAME')
REGION_NAME = os.environ.get('AWS_REGION', 'us-east-1')

# Environment variable for the S3 bucket name
S3_BUCKET = os.environ.get('S3_BUCKET')

# Local paths used by the Lambda function
SCHEMA_FILE_PATH = './db.sql'
DATASET_FILE_PATH = '/tmp/combined_data.csv'
TEMP_DOWNLOAD_PATH = '/tmp/temp_download.csv'

def get_secret():
    """Retrieve the RDS password from AWS Secrets Manager."""
    print("Starting get_secret function")
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=REGION_NAME)

    try:
        print(f"Attempting to retrieve secret: {SECRET_NAME} in region: {REGION_NAME}")
        get_secret_value_response = client.get_secret_value(SecretId=SECRET_NAME)
        secret = get_secret_value_response['SecretString']
        secret_dict = json.loads(secret)
        print("Secret retrieved successfully")
        return secret_dict['password']
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        raise

def execute_schema(cursor):
    """Read and execute SQL statements from the schema file to create DB structure."""
    print(f"Starting execute_schema function using file: {SCHEMA_FILE_PATH}")
    try:
        with open(SCHEMA_FILE_PATH, 'r') as f:
            schema_sql = f.read()
            print(f"Schema file loaded, size: {len(schema_sql)} characters")

        statements = schema_sql.split(';')
        print(f"Found {len(statements)} SQL statements to execute")

        for idx, statement in enumerate(statements):
            stmt = statement.strip()
            if stmt:
                print(f"Executing SQL statement {idx + 1}/{len(statements)}")
                # For statements that might return results like SHOW TABLES
                cursor.execute(stmt)
                if stmt.upper().startswith('SHOW'):
                    result = cursor.fetchall()
                    print(f"Query result: {result}")
        print("Schema executed successfully")
    except Exception as e:
        print(f"Error executing schema: {e}")
        raise

def download_file_from_s3(bucket, key, local_path=DATASET_FILE_PATH):
    """Download a file from S3 and save it to the specified path."""
    print(f"Starting download_file_from_s3 function. Bucket: {bucket}, Key: {key}")
    s3 = boto3.client('s3')
    try:
        s3.download_file(bucket, key, local_path)
        print(f"Downloaded {key} from bucket {bucket} to {local_path}")
        
        if os.path.exists(local_path):
            file_size = os.path.getsize(local_path)
            print(f"File downloaded successfully. Size: {file_size} bytes")
        else:
            print(f"Warning: File not found at {local_path} after download")
    except Exception as e:
        print(f"Error downloading file from S3: {e}")
        raise

def list_csv_files_in_folder(bucket, prefix='data-sets/'):
    """List all CSV files in the specified S3 folder."""
    print(f"Listing CSV files in s3://{bucket}/{prefix}")
    s3 = boto3.client('s3')
    
    try:
        response = s3.list_objects_v2(
            Bucket=bucket,
            Prefix=prefix
        )
        
        csv_files = []
        if 'Contents' in response:
            for obj in response['Contents']:
                key = obj['Key']
                if key.lower().endswith('.csv'):
                    csv_files.append(key)
                    
        print(f"Found {len(csv_files)} CSV files in the folder")
        return csv_files
    except Exception as e:
        print(f"Error listing files in S3: {e}")
        raise

def combine_csv_files(bucket, file_keys):
    """Download and combine multiple CSV files, removing duplicates based on username."""
    print(f"Combining {len(file_keys)} CSV files from S3")
    
    all_rows = []
    fieldnames = set()
    username_index = {}  # To track latest entry for each username
    
    if not file_keys:
        print("No CSV files found to combine")
        return {'no_files': True}
    
    for i, key in enumerate(file_keys):
        print(f"Processing file {i+1}/{len(file_keys)}: {key}")
        try:
            # Download the file to a temporary location
            download_file_from_s3(bucket, key, TEMP_DOWNLOAD_PATH)
            
            # Read the CSV file
            with open(TEMP_DOWNLOAD_PATH, 'r') as csvfile:
                reader = csv.DictReader(csvfile)
                
                # Update our combined fieldnames
                fieldnames.update(reader.fieldnames or [])
                
                # Process each row
                for row in reader:
                    username = row.get('Username', '')
                    if not username:
                        print(f"Skipping row without username in file {key}")
                        continue
                        
                    # If this username already exists, replace the previous entry
                    if username in username_index:
                        all_rows[username_index[username]] = row
                    else:
                        # Add new row and store its index
                        username_index[username] = len(all_rows)
                        all_rows.append(row)
                        
        except Exception as e:
            print(f"Error processing file {key}: {e}")
            # Continue with other files even if one fails
    
    print(f"Combined data has {len(all_rows)} unique rows across {len(fieldnames)} fields")
    
    # Write the combined data to the output file
    with open(DATASET_FILE_PATH, 'w', newline='') as outfile:
        writer = csv.DictWriter(outfile, fieldnames=list(fieldnames))
        writer.writeheader()
        writer.writerows(all_rows)
    
    print(f"Combined CSV written to {DATASET_FILE_PATH}")
    return {
        'combined_rows': len(all_rows),
        'source_files': len(file_keys),
        'fields': list(fieldnames)
    }

def reset_auto_increment(cursor):
    """Reset the auto-increment counter to ensure sequential IDs without gaps."""
    print("Resetting auto-increment counter to ensure sequential IDs")
    try:
        # Get the count of rows in the table
        cursor.execute("SELECT COUNT(*) as row_count FROM user_portal.users")
        result = cursor.fetchone()
        row_count = result['row_count']
        
        if row_count == 0:
            # If table is empty, reset to 1
            cursor.execute("ALTER TABLE user_portal.users AUTO_INCREMENT = 1")
            print("Table is empty, reset AUTO_INCREMENT to 1")
            return
        
        # Get the current maximum ID
        cursor.execute("SELECT MAX(id) as max_id FROM user_portal.users")
        result = cursor.fetchone()
        max_id = result['max_id'] if result and result['max_id'] is not None else 0
        
        # Get all IDs in order
        cursor.execute("SELECT id FROM user_portal.users ORDER BY id")
        ids = [row['id'] for row in cursor.fetchall()]
        
        # Find missing sequence numbers
        missing = []
        for i in range(1, max_id):
            if i not in ids:
                missing.append(i)
        
        if missing:
            print(f"Found {len(missing)} gaps in ID sequence: {missing[:10]}{'...' if len(missing) > 10 else ''}")
            
            # Reorganize IDs to fill gaps and make them sequential
            if len(missing) > 0:
                print("Reorganizing IDs to make them sequential...")
                # Create a temporary table with the same structure
                cursor.execute("CREATE TEMPORARY TABLE temp_users LIKE user_portal.users")
                
                # Copy data to temp table, ordered by ID
                cursor.execute("INSERT INTO temp_users SELECT * FROM user_portal.users ORDER BY id")
                
                # Truncate the original table
                cursor.execute("TRUNCATE TABLE user_portal.users")
                
                # Reset auto_increment
                cursor.execute("ALTER TABLE user_portal.users AUTO_INCREMENT = 1")
                
                # Copy data back, IDs will be assigned sequentially
                cursor.execute("INSERT INTO user_portal.users (title, firstname, lastname, status, username, password, age) SELECT title, firstname, lastname, status, username, password, age FROM temp_users")
                
                # Drop temporary table
                cursor.execute("DROP TEMPORARY TABLE temp_users")
                
                print("ID sequence reorganized successfully")
        else:
            # If no gaps, just make sure next ID is set correctly
            cursor.execute(f"ALTER TABLE user_portal.users AUTO_INCREMENT = {max_id + 1}")
            print(f"No gaps in sequence, AUTO_INCREMENT set to {max_id + 1}")
            
    except Exception as e:
        print(f"Error resetting auto-increment sequence: {e}")
        # Continue processing even if this fails

def is_valid_username(username):
    # Username must be alphanumeric and 3-100 characters long, dots allowed but not at start/end or consecutive
    return re.match(r'^(?!.*\.\.)(?!\.)(?!.*\.$)[a-zA-Z0-9.]{3,100}$', username) is not None

def is_valid_name(name):
    # Name must be alphabetic and 1-50 characters long
    return re.match(r'^[a-zA-Z0-9]{1,50}$', name) is not None


def is_valid_age(age):
    try:
        age_int = int(age)
        return 0 < age_int < 150
    except:
        return False

def is_valid_title(title):
    valid_titles = {"Mr", "Ms", "Mrs", "Dr", "Prof", "Lt"}
    return title in valid_titles

def insert_data(cursor):
    """Read data from the CSV file and insert it into the user_portal.users table using ON DUPLICATE KEY UPDATE."""
    print(f"Starting insert_data function using file: {DATASET_FILE_PATH}")
    
    # Track statistics for reporting
    stats = {
        'total': 0,
        'processed': 0,
        'inserted': 0,
        'skipped': 0,
        'errors': 0,
        'validation_errors': 0
    }
    
    try:
        with open(DATASET_FILE_PATH, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            rows = list(reader)
            print(f"CSV file loaded, found {len(rows)} rows to process")
            stats['total'] = len(rows)

            # First, check which usernames already exist to separate inserts from updates
            existing_usernames = set()
            usernames = [row.get('Username', '') for row in rows if row.get('Username')]
            
            if usernames:
                placeholders = ', '.join(['%s'] * len(usernames))
                query = f"SELECT username FROM user_portal.users WHERE username IN ({placeholders})"
                cursor.execute(query, usernames)
                existing_usernames = {row['username'] for row in cursor.fetchall()}
                
                print(f"Found {len(existing_usernames)} existing usernames in database")

            # Track skipped usernames for logging
            skipped_usernames = []
            validation_error_rows = []
            
            # Process each row
            for idx, row in enumerate(rows):
                username = row.get('Username', '')
                firstname = row.get('First Name', '')
                lastname = row.get('Last Name', '')
                age = row.get('Age', '')
                title = row.get('Title', '')
                print(f"Processing row {idx + 1}/{len(rows)}: Username={username}")
                
                # Validate fields
                if not is_valid_username(username):
                    print(f"Validation failed for username: {username}")
                    validation_error_rows.append({'row': idx + 1, 'error': 'Invalid username', 'username': username})
                    stats['validation_errors'] += 1
                    stats['processed'] += 1
                    continue
                if not is_valid_name(firstname) or not is_valid_name(lastname):
                    print(f"Validation failed for name: {firstname} {lastname}")
                    validation_error_rows.append({'row': idx + 1, 'error': 'Invalid name', 'username': username})
                    stats['validation_errors'] += 1
                    stats['processed'] += 1
                    continue
                if not is_valid_age(age):
                    print(f"Validation failed for age: {age}")
                    validation_error_rows.append({'row': idx + 1, 'error': 'Invalid age', 'username': username})
                    stats['validation_errors'] += 1
                    stats['processed'] += 1
                    continue
                if not is_valid_title(title):
                    print(f"Validation failed for title: {title}")
                    validation_error_rows.append({'row': idx + 1, 'error': 'Invalid title', 'username': username})
                    stats['validation_errors'] += 1
                    stats['processed'] += 1
                    continue
                
                try:
                    if username in existing_usernames:
                        # Skip existing usernames instead of updating
                        print(f"Skipping existing username: {username}")
                        skipped_usernames.append({
                            'username': username,
                            'title': title,
                            'firstname': firstname,
                            'lastname': lastname,
                            'status': row.get('Status', ''),
                            'age': age
                        })
                        stats['skipped'] += 1
                        stats['processed'] += 1
                        continue
                    else:
                        # Insert new user
                        cursor.execute(
                            """
                            INSERT INTO user_portal.users
                            (title, firstname, lastname, status, username, password, age)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                            """,
                            (
                                title,
                                firstname,
                                lastname,
                                int(row.get('Status', 0)),
                                username,
                                row.get('Password', ''),
                                int(age)
                            )
                        )
                        stats['inserted'] += 1
                        # Add to our set of existing usernames for subsequent rows
                        existing_usernames.add(username)
                        stats['processed'] += 1
                        
                except Exception as e:
                    print(f"Error processing row for username {username}: {e}")
                    stats['errors'] += 1
            
            # Get the current max ID to use in the reset
            reset_auto_increment(cursor)
                    
        # Log the skipped usernames
        if skipped_usernames:
            print(f"Skipped {len(skipped_usernames)} existing usernames:")
            for user in skipped_usernames:
                print(f"  - {user['username']} ({user['firstname']} {user['lastname']})")
        
        # Log validation errors
        if validation_error_rows:
            print(f"Validation errors in {len(validation_error_rows)} rows:")
            for err in validation_error_rows:
                print(f"  - Row {err['row']}: {err['error']} (Username: {err['username']})")
        
        # Reset auto-increment to ensure sequential IDs
        reset_auto_increment(cursor)
            
        print(f"Data processing complete. Stats: {json.dumps(stats)}")
        return {
            'stats': stats,
            'skipped_users': skipped_usernames,
            'validation_errors': validation_error_rows
        }
    except Exception as e:
        print(f"Error inserting data: {e}")
        raise

def process_single_file(bucket, key):
    """Process a single CSV file from S3."""
    print(f"Processing single file: s3://{bucket}/{key}")
    
    try:
        print("Retrieving DB credentials from Secrets Manager")
        password = get_secret()

        print("Connecting to the RDS database")
        connection = pymysql.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=password,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )
        print("Database connection established")

        try:
            print("Downloading file from S3")
            download_file_from_s3(bucket, key)

            print("Opening database cursor for schema and data insertion")
            with connection.cursor() as cursor:
                print("Executing schema setup")
                execute_schema(cursor)

                print("Inserting CSV data in the database (skipping existing usernames)")
                result = insert_data(cursor)

            return {
                'statusCode': 200, 
                'body': json.dumps({
                    'message': 'Schema created and data processed successfully.',
                    'stats': result['stats'],
                    'skipped_users_count': len(result['skipped_users']),
                    'file_processed': key
                })
            }

        except Exception as e:
            print(f"Error during DB operations: {e}")
            return {'statusCode': 500, 'body': json.dumps(f"Error: {str(e)}")}

        finally:
            print("Closing DB connection")
            connection.close()

    except Exception as e:
        print(f"Fatal error in processing file: {e}")
        return {'statusCode': 500, 'body': json.dumps(f"Fatal error: {str(e)}")}

def process_daily_files(bucket):
    """Process all CSV files in the data-sets folder for daily scheduled run."""
    print(f"Running daily processing for all CSV files in bucket: {bucket}")
    
    try:
        # List all CSV files in the data-sets folder
        csv_files = list_csv_files_in_folder(bucket, 'data-sets/')
        
        if not csv_files:
            print("No CSV files found in the data-sets/ folder")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'No CSV files found to process for daily run.',
                })
            }
            
        # Combine all CSV files, removing duplicates
        print("Combining CSV files and removing duplicates")
        combine_stats = combine_csv_files(bucket, csv_files)
        
        # Connect to the database
        print("Retrieving DB credentials from Secrets Manager")
        password = get_secret()

        print("Connecting to the RDS database")
        connection = pymysql.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=password,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )
        print("Database connection established")

        try:
            print("Opening database cursor for schema and data insertion")
            with connection.cursor() as cursor:
                print("Executing schema setup")
                execute_schema(cursor)

                print("Inserting combined CSV data in the database (skipping existing usernames)")
                result = insert_data(cursor)

            return {
                'statusCode': 200, 
                'body': json.dumps({
                    'message': 'Daily processing completed successfully.',
                    'combine_stats': combine_stats,
                    'db_stats': result['stats'],
                    'skipped_users_count': len(result['skipped_users']),
                    'files_processed': csv_files
                })
            }

        except Exception as e:
            print(f"Error during DB operations: {e}")
            return {'statusCode': 500, 'body': json.dumps(f"Error: {str(e)}")}

        finally:
            print("Closing DB connection")
            connection.close()

    except Exception as e:
        print(f"Fatal error in daily processing: {e}")
        return {'statusCode': 500, 'body': json.dumps(f"Fatal error: {str(e)}")}

def lambda_handler(event, context):
    """Main Lambda function handler triggered by S3 events or scheduled events."""
    print("Lambda function started")
    print(f"Received event: {json.dumps(event)}")
    
    # Check if this is a scheduled event (CloudWatch EventBridge)
    if 'source' in event and event['source'] == 'aws.events':
        print("Processing scheduled daily event")
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"Scheduled execution at {current_time}")
        
        # Process all files in the data-sets folder
        bucket = S3_BUCKET
        return process_daily_files(bucket)
    
    # Check if this is an S3 event
    elif 'Records' in event and event['Records'][0].get('eventSource') == 'aws:s3':
        print("Processing S3 event")
        
        # Extract bucket and object key from S3 event
        try:
            s3_event = event['Records'][0]['s3']
            bucket = s3_event['bucket']['name']
            key = urllib.parse.unquote_plus(s3_event['object']['key'])

            print(f"Triggered by file upload: s3://{bucket}/{key}")

            # Ignore non-CSV files
            if not key.lower().endswith('.csv'):
                print(f"Ignoring non-CSV file: {key}")
                return {'statusCode': 200, 'body': json.dumps('Ignored non-CSV file.')}

            # Ensure file is in the expected prefix
            if not key.startswith('data-sets/'):
                print(f"File not in expected path: {key}")
                return {'statusCode': 200, 'body': json.dumps('File not in expected path, ignoring.')}
                
            return process_single_file(bucket, key)

        except Exception as e:
            print(f"Error parsing S3 event: {e}")
            return {'statusCode': 400, 'body': json.dumps('Error parsing S3 event.')}
    
    else:
        print("Received unknown event type")
        return {'statusCode': 400, 'body': json.dumps('Unknown event type.')}