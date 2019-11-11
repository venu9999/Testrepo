#!/bin/bash
PROD_INSTANCE_IDENTIFIER=prod-core-aurora-cluster
DEV_CLUSTER_IDENTIFIER=venu-core-aurora-cluster
DEV_INSTANCE_IDENTIFIER=venu-core-aurora
DEV_INSTANCE_CLASS=db.r5.large
SUBNET_GROUP=qa-db-subnet
SECURITY_GROUP_ID=sg-1d8e7379
PARAMETER_GROUP=custom-aurora56	
RETENTION_PERIOD=7
DATE=`date +%Y-%m-%d-%k-%M`


fail_check() {
	if [ $? -ne 0 ]
	then
		echo "Fail"
		exit 1
	else
		echo "Ok"
	fi

}


echo "Finding latest snapshot for $PROD_INSTANCE_IDENTIFIER"
LATEST_SNAPSHOT_ID=$( aws rds describe-db-cluster-snapshots --db-cluster-identifier $PROD_INSTANCE_IDENTIFIER --query 'DBClusterSnapshots[-1].[DBClusterSnapshotIdentifier]' --output text )
fail_check
echo $LATEST_SNAPSHOT_ID

echo "Checking for an existing instance $DEV_INSTANCE_IDENTIFIER"
EXISTING_DEV_INSTANCE=$( aws rds describe-db-instances --db-instance-identifier $DEV_INSTANCE_IDENTIFIER --query 'DBInstances[0].[DBInstanceIdentifier]' --output text )

if [ "${EXISTING_DEV_INSTANCE}" == "${DEV_INSTANCE_IDENTIFIER}" ];
then
    echo "Deleting existing instance found with identifier ${DEV_INSTANCE_IDENTIFIER}"
    aws rds delete-db-instance \
    --db-instance-identifier $DEV_INSTANCE_IDENTIFIER --skip-final-snapshot
    aws rds wait db-instance-deleted --db-instance-identifier $DEV_INSTANCE_IDENTIFIER
    fail_check
    echo "Finished deleting ${DEV_INSTANCE_IDENTIFIER}"
else
echo "no instance found with identifier ${DEV_INSTANCE_IDENTIFIER}"
fi

echo "Checking for an existing cluster $DEV_CLUSTER_IDENTIFIER"
EXISTING_DEV_CLUSTER=$( aws rds describe-db-clusters --db-cluster-identifier $DEV_CLUSTER_IDENTIFIER --query 'DBClusters[0].[DBClusterIdentifier]' --output text )

if [ "${EXISTING_DEV_CLUSTER}" == "${DEV_CLUSTER_IDENTIFIER}" ];
then
    echo "Deleting existing cluster found with identifier ${DEV_CLUSTER_IDENTIFIER}"
    aws rds --skip-final-snapshot delete-db-cluster --db-cluster-identifier $DEV_CLUSTER_IDENTIFIER 
    sleep 120
    echo "Finished deleting ${DEV_CLUSTER_IDENTIFIER}"
else
echo "no cluster found with identifier ${DEV_CLUSTER_IDENTIFIER}"
fi


echo "Restoring snapshot ${LATEST_SNAPSHOT_ID} to a new db cluster ${DEV_CLUSTER_IDENTIFIER}..."
aws rds restore-db-cluster-from-snapshot \
    --db-cluster-identifier $DEV_CLUSTER_IDENTIFIER \
    --snapshot-identifier $LATEST_SNAPSHOT_ID \
    --port 3306 \
    --engine aurora \
    --engine-version 5.6.10a \
    --engine-mode provisioned \
    --vpc-security-group-ids $SECURITY_GROUP_ID \
    --db-subnet-group-name $SUBNET_GROUP 
fail_check


echo "Creating member instance for ${DEV_CLUSTER_IDENTIFIER}"

aws rds create-db-instance \
    --db-instance-identifier ${DEV_INSTANCE_IDENTIFIER} \
    --db-instance-class $DEV_INSTANCE_CLASS \
    --engine aurora \
    --db-parameter-group-name $PARAMETER_GROUP \
    --db-subnet-group-name $SUBNET_GROUP \
    --db-cluster-identifier ${DEV_CLUSTER_IDENTIFIER}
fail_check

status=unknown
while [[ "$status" != "available" ]]; do
  sleep 30
  status=`aws rds describe-db-clusters --db-cluster-identifier $DEV_CLUSTER_IDENTIFIER | jq -r '.DBClusters[0].Status'`
  echo "${DEV_CLUSTER_IDENTIFIER} cluster state is: ${status}"
done

echo "Finished creating ${DEV_CLUSTER_IDENTIFIER} from snapshot ${LATEST_SNAPSHOT_ID}"


while [ "${exit_status}" != "0" ]
do
    echo "Waiting for ${DEV_INSTANCE_IDENTIFIER} to enter 'available' state..."
    aws rds wait db-instance-available --db-instance-identifier $DEV_INSTANCE_IDENTIFIER
    exit_status="$?"

    INSTANCE_STATUS=$( aws rds describe-db-instances --db-instance-identifier $DEV_INSTANCE_IDENTIFIER --query 'DBInstances[0].[DBInstanceStatus]' --output text )
    echo "${DEV_INSTANCE_IDENTIFIER} instance state is: ${INSTANCE_STATUS}"
done
echo "Finished creating instance ${DEV_INSTANCE_IDENTIFIER}"
echo "Updating password"
aws ssm get-parameter --name db_password --with-decryption --region us-east-1 --output text >> params
fail_check
export PASSWORD=$(grep db_password params | tail -1 | awk '{print $6}')
fail_check
aws rds modify-db-cluster --db-cluster-identifier $DEV_CLUSTER_IDENTIFIER --master-user-password $PASSWORD --apply-immediately
sleep 30

HOST_ADDRESS=$(aws rds describe-db-clusters --db-cluster-identifier $DEV_CLUSTER_IDENTIFIER --query 'DBClusters[0].Endpoint' --output text )

echo "Updating skuro password"
aws ssm get-parameter --name skuro_password --with-decryption --region us-east-1 --output text >> params1
fail_check
export USER_PASSWORD=$(grep skuro_password params1 | tail -1 | awk '{print $6}')
fail_check
echo "UPDATE mysql.user SET Password=PASSWORD('$USER_PASSWORD') WHERE User='skuro'; FLUSH PRIVILEGES;" | mysql -h $HOST_ADDRESS -u skuroot -p$PASSWORD skubana

echo "obscurify prod data and disable all accounts"
mysql -h $HOST_ADDRESS -u skuroot -p$PASSWORD skubana < scrub_dev_db.sql
echo "finished data scrub"


echo "done done"

