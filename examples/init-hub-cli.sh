## You can download external plugins from confluent-hub cli

echo "## Waiting for Kafka Connect to start"
CNT=0
while :; do
  ((CNT++)); echo "count = $CNT"
  confluent-hub install --no-prompt  confluentinc/kafka-connect-elasticsearch:latest
  [ $? -eq 0 ] && break
  sleep 2
done
