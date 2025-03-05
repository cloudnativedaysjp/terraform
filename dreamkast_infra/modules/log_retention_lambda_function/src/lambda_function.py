import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Set retention period to 14 days (2 weeks)
RETENTION_PERIOD_DAYS = 14

def lambda_handler(event, context):
    """
    AWS Lambda function to update CloudWatch Logs log groups with no expiration (never expire)
    to a 14-day retention period.
    
    Args:
        event: AWS Lambda event object
        context: AWS Lambda context object
        
    Returns:
        dict: Summary of the operation
    """
    logger.info(f"Starting log group retention check. Setting retention to {RETENTION_PERIOD_DAYS} days for log groups with no expiration.")
    
    # Initialize counters
    processed_count = 0
    updated_count = 0
    
    try:
        # Create CloudWatch Logs client
        logs_client = boto3.client('logs')
        
        # Pagination token
        next_token = None
        
        # Process all log groups
        while True:
            # Get log groups, 50 at a time (AWS API limit)
            if next_token:
                response = logs_client.describe_log_groups(
                    nextToken=next_token,
                    limit=50
                )
            else:
                response = logs_client.describe_log_groups(
                    limit=50
                )
            
            # Get pagination token for next iteration
            next_token = response.get('nextToken')
            
            # Process log groups in current batch
            log_groups = response.get('logGroups', [])
            processed_count += len(log_groups)
            
            for log_group in log_groups:
                # Check if log group has no retention (never expire)
                if 'retentionInDays' not in log_group:
                    log_group_name = log_group.get('logGroupName')
                    
                    if log_group_name:
                        logger.info(f"Updating log group: {log_group_name} to {RETENTION_PERIOD_DAYS} days retention")
                        
                        try:
                            # Set retention policy to 14 days
                            logs_client.put_retention_policy(
                                logGroupName=log_group_name,
                                retentionInDays=RETENTION_PERIOD_DAYS
                            )
                            
                            updated_count += 1
                            logger.info(f"Successfully updated retention for: {log_group_name}")
                        except Exception as e:
                            logger.error(f"Error updating retention for log group {log_group_name}: {str(e)}")
            
            # Exit loop if no more log groups
            if not next_token:
                break
        
        summary = f"Completed processing {processed_count} log groups. Updated {updated_count} log groups to {RETENTION_PERIOD_DAYS} days retention."
        logger.info(summary)
        
        return {
            'statusCode': 200,
            'processed': processed_count,
            'updated': updated_count,
            'message': summary
        }
        
    except Exception as e:
        error_message = f"Error processing log groups: {str(e)}"
        logger.error(error_message)
        raise