-- Create/Drop DBA Directories & Grant Access
DROP directory STAGE_DIR;
CREATE directory STAGE_DIR AS 'fbdi/gljournal';

-- Get all dba directories
SELECT * FROM dba_directories;

-- Grant access to DBA Directory
GRANT READ,WRITE ON directory STAGE_DIR TO adb_user;

-- Grant access to DBMS_CLOUD API
GRANT EXECUTE ON DBMS_CLOUD TO adb_user;

-- List files from DBA Directory
SELECT * FROM DBMS_CLOUD.LIST_FILES('STAGE_DIR');

-- Delete file from DBA Directory
BEGIN
  DBMS_CLOUD.DELETE_FILE ( 
       directory_name     => 'STAGE_DIR',
       file_name          => 'data.csv');
END;

-- Create Credentials for Object Storage
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'DEF_CRED_NAME',
    username => 'user1@example.com',
    password => 'password'
  );
END;
/

-- Put File from DBA Directory to Object Storage
BEGIN
   DBMS_CLOUD.PUT_OBJECT(credential_name => 'DEF_CRED_NAME',
     object_uri => 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/namespace-string/b/bucketname/o/data.csv',
     directory_name => 'STAGE_DIR',
     file_name => 'data.csv');
END;
/

-- Get File from Object Storage to DBA Directory
BEGIN
   DBMS_CLOUD.GET_OBJECT(
   credential_name => 'DEF_CRED_NAME',
   object_uri => 'https://objectstorage.usphoenix-1.oraclecloud.com/n/namespace-string/b/bucketname/o/cwallet.sso',
   directory_name => 'STAGE_DIR');
END;
/