#! /usr/bin/python3
import argparse
import configparser
import json
import MySQLdb
import re
import sys

parser = argparse.ArgumentParser(prog='Clean Roles from Trust',
    description='This program cleans certain roles from the keystone trusts')
parser.add_argument('-c', '--commit', action='store_true')
parser.add_argument('-r', '--role', help='Name or ID of role to clean', required=True)
parser.add_argument('--skip-role-validation', help='Take the role provides as an ID without verifying its existence', action='store_true')
parser.add_argument('-v', '--verbose', action='store_true')
args = parser.parse_args()

USERCACHE = {}

def connect_to_database():
    # Read the keystone-config to retrieve the DB connection string
    config = configparser.ConfigParser()
    config.read(['/etc/keystone/keystone.conf'])
    try:
        dbstr = config.get('database', 'connection')
    except configparser.NoSectionError:
        print("This script must be run from a keystone-box.")
        sys.exit(1)
    
    # Parse the connection-string and extract the database credentials
    try:
        p = re.compile(r'.*//([a-zA-Z]+):(.*)@(.*)/(.*)')
        m = p.match(dbstr)
        dbuser, dbpass, dbhost, dbname = m.groups()
    except Exception:
        print("Could not determins database credentials")
        sys.exit(2)
    
    return MySQLdb.connect(dbhost, dbuser, dbpass, dbname)

def validate_role(db, role):
    if(args.skip_role_validation):
        return args.role
    else:
        # Verify the role ID
        c = db.cursor()
        c.execute("SELECT id, name from role WHERE id = '%s' or name = '%s'" % (args.role, args.role))
        roles = c.fetchall()
        
        if(len(roles) != 1):
            print("Found %d roles in the database matching %s." % (len(roles), args.role))
            sys.exit(3)
        else:
            return roles[0][0]

def get_username(db, user_id):
    if(user_id not in USERCACHE):
        c = db.cursor()
        username = None

        try:
            c.execute("SELECT name FROM local_user WHERE user_id = '%s'" % user_id)
            username = c.fetchone()[0]
        except TypeError:
          try:
              c.execute("SELECT local_id FROM id_mapping WHERE public_id = '%s'" % user_id)
              username = c.fetchone()[0]
          except TypeError:
              pass

        USERCACHE[user_id] = username if username else user_id
    return USERCACHE[user_id]

def main():
    db = connect_to_database()

    if(args.skip_role_validation):
        role_id = args.role
    else:
        role_id = validate_role(db, args.role)
    
    c = db.cursor()
    c.execute("SELECT id, extra, trustor_user_id, trustee_user_id FROM trust WHERE deleted_at IS NULL")
    for row in c.fetchall():
        trustee = get_username(db, row[2])
        trustor = get_username(db, row[3])
        data = json.loads(row[1])
        roles = []
        for role in data['roles']:
            if role['id'] != role_id:
                roles.append(role)
    
        if(len(data['roles']) != len(roles)):
            if args.commit:
                data['roles'] = roles
                print("Removing the role at trust %s from trustee %s to trustor %s" % (row[0], trustee, trustor))
                c2 = db.cursor()
                c2.execute("UPDATE trust SET extra = '%s' WHERE id = '%s'" % (json.dumps(data), row[0]))
            else:
                print("Would remove the role at trust %s from trustee %s to trustor %s" % (row[0], trustee, trustor))

    if args.commit:
        c.execute("DELETE FROM trust_role WHERE role_id = '%s' and trust_id IN (SELECT id FROM trust WHERE deleted_at IS NULL)" % role_id)
        db.commit()
    else:
        c.execute("SELECT * FROM trust_role WHERE role_id = '%s' and trust_id IN (SELECT id FROM trust WHERE deleted_at IS NULL)" % role_id)
        print("Would have deleted %d rows from trust_role" % len(c.fetchall()))

if __name__ == "__main__":
    main()
