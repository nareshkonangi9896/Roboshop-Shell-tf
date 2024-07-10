INSTANCE_NAME=("web" "mongodb" "redis" "mysql" "rabbitmq")
HOSTED_ZONE=Z05436162VP5EXTPZDANB
DOMAIN_NAME=nareshdevops.online
SECURTIY_ID=sg-0be37408ceee761c1
AMI_ID=ami-0f3c7d07486cad139


for i in "${INSTANCE_NAME[@]}"
do
    echo "creating $i"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --security-group-ids $SECURTIY_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"| jq -r '.Instances[0].PrivateIpAddress')
    echo "created instance $i : $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch '
    {
            "Comment": "CREATE/DELETE/UPSERT a record ",
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 1,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                                            }
                        }]
    }'
done