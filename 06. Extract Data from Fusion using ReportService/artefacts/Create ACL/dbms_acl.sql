-- Grant execute permission on UTL_HTTP to ADB_USER
GRANT EXECUTE ON utl_http TO adb_user;

-- Create ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl => 'adbuser.xml',
    description => 'Permissions to access web service',
    principal => 'ADB_USER',
    is_grant => TRUE,
    privilege => 'connect',
    start_date => SYSTIMESTAMP,
    end_date => NULL
  );
  COMMIT;
END;
/

-- Add Privilege
BEGIN
  DBMS_NETWORK_acl_ADMIN.ADD_PRIVILEGE(
    acl => 'adbuser.xml',
    principal => 'ADB_USER',
    is_grant => true,
    privilege => 'resolve',
	start_date => NULL,
    end_date => NULL
  );
 COMMIT;
END;
/ 

-- Assign ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
    acl => 'adbuser.xml',
    host => '*',
	lower_port  => NULL,
    upper_port  => NULL
  );
COMMIT;
END;
/

-- Fetch ACL Details
SELECT acl , host , lower_port , upper_port FROM DBA_NETWORK_ACLS;

SELECT acl , principal , privilege , is_grant FROM DBA_NETWORK_ACL_PRIVILEGES;


--Unassign ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.unassign_acl (
    acl         => 'test_acl_file.xml',
    host        => '192.168.2.3', 
    lower_port  => 80,
    upper_port  => NULL); 

  COMMIT;
END;
/

-- Drop ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl (
    acl => 'adbuser.xml'
  );
  COMMIT;
END;
/