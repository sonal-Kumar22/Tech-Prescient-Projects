#API Gateway endpoint which triggers lambda 1 - publisher lambda
# API Gateway - endpoint 1
resource "aws_api_gateway_rest_api" "api_1" {
  name = "rbac-dev"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#API Gateway resource
resource "aws_api_gateway_resource" "publisher_lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_1.id
  parent_id   = aws_api_gateway_rest_api.api_1.root_resource_id
  path_part   = "provision"
}

resource "aws_api_gateway_method" "publisher_lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_1.id
  resource_id   = aws_api_gateway_resource.publisher_lambda_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true #for setting value of API_Key as required in method 
}


/*
resource "aws_api_gateway_method" "publisher_lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_1.id
  resource_id   = aws_api_gateway_rest_api.api_1.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true #for setting value of API_Key as required in method 
}
*/
resource "aws_api_gateway_integration" "publisher_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_1.id
  #resource_id             = aws_api_gateway_rest_api.api_1.root_resource_id
  resource_id             = aws_api_gateway_resource.publisher_lambda_resource.id
  http_method             = aws_api_gateway_method.publisher_lambda_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.publisher_lambda_func.invoke_arn
}

#method response
resource "aws_api_gateway_method_response" "publisher_lambda_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_1.id
  #resource_id = aws_api_gateway_rest_api.api_1.root_resource_id
  resource_id = aws_api_gateway_resource.publisher_lambda_resource.id
  http_method = aws_api_gateway_method.publisher_lambda_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
}
}

#integration response
resource "aws_api_gateway_integration_response" "publisher_IntegrationResponse" {
   rest_api_id = aws_api_gateway_rest_api.api_1.id
   #resource_id = aws_api_gateway_rest_api.api_1.root_resource_id
   resource_id = aws_api_gateway_resource.publisher_lambda_resource.id
   http_method = aws_api_gateway_method.publisher_lambda_method.http_method
   status_code = "200"

   response_templates = {
       "application/json" = ""
   } 
}

# endpoint 1 triggers publisher lambda 
# Lambda Permissions : Gives an external source (like an EventBridge Rule, SNS, or S3) permission to access the Lambda function.
resource "aws_lambda_permission" "publisher_lambda_trigger" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.publisher_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.accountId}:${aws_api_gateway_rest_api.api_1.id}/*/${aws_api_gateway_method.publisher_lambda_method.http_method}${aws_api_gateway_rest_api.api_1.root_resource_id}"
  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.accountId}:${aws_api_gateway_rest_api.api_1.id}/*/${aws_api_gateway_method.publisher_lambda_method.http_method}${aws_api_gateway_resource.publisher_lambda_resource.path}"
  #source_arn = "${aws_api_gateway_rest_api.api_1.execution_arn}/*/*/*"
}


#API Gateway endpoint which triggers lambda 3 - reprovisioning lambda
# API Gateway - endpoint 2

#API Gateway resource
resource "aws_api_gateway_resource" "reprovisioning_lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_1.id
  parent_id   = aws_api_gateway_rest_api.api_1.root_resource_id
  path_part   = "reprovision"
}

resource "aws_api_gateway_method" "reprovisioning_lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_1.id
  resource_id   = aws_api_gateway_resource.reprovisioning_lambda_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true #for setting value of API_Key as required in method 
}

resource "aws_api_gateway_integration" "reprovisioning_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_1.id
  resource_id             = aws_api_gateway_resource.reprovisioning_lambda_resource.id
  http_method             = aws_api_gateway_method.reprovisioning_lambda_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.reprovisioning_lambda_func.invoke_arn
}


#method response
resource "aws_api_gateway_method_response" "reprovisioning_lambda_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_1.id
  resource_id = aws_api_gateway_resource.reprovisioning_lambda_resource.id
  http_method = aws_api_gateway_method.reprovisioning_lambda_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
}
}

#integration response
resource "aws_api_gateway_integration_response" "reprovisioning_IntegrationResponse" {
   rest_api_id = aws_api_gateway_rest_api.api_1.id
   resource_id = aws_api_gateway_resource.reprovisioning_lambda_resource.id
   http_method = aws_api_gateway_method.reprovisioning_lambda_method.http_method
   status_code = "200"

   response_templates = {
       "application/json" = ""
   } 
}

# endpoint 2 triggers reprovisioning lambda
# Lambda Permissions : Gives an external source (like an EventBridge Rule, SNS, or S3) permission to access the Lambda function.
resource "aws_lambda_permission" "reprovisioning_lambda_trigger" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reprovisioning_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.accountId}:${aws_api_gateway_rest_api.api_1.id}/*/${aws_api_gateway_method.reprovisioning_lambda_method.http_method}${aws_api_gateway_resource.reprovisioning_lambda_resource.path}"
}

#Create lambda 1 : publisher_lambda , lambda permissions
#IAM Role creation for lambdas 1,3 : Role 1
resource "aws_iam_role" "Publisher_and_Reprovisioning_Lambdas_Role" {
name   = "rbac_lambda_access_to_sqs"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

#IAM Policy : SQS full Access
resource "aws_iam_policy" "sqs_access_policy" {
  name        = "sqs_full_access_policy"
  description = "policy for read, write SQS Access"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sqs:SendMessage",  # read,write
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:ListDeadLetterSourceQueues",
                "sqs:ListQueues"
            ],
            "Effect": "Allow",
            "Resource": "${aws_sqs_queue.sqs_queue.arn}"  #mention queue arn 
        }
    ]
})
}

#IAM Policy : Cloudwatch full access
resource "aws_iam_policy" "cloudwatchlogs_access_policy" {
  name        = "cloudwatchlogs_full_access_policy"
  description = "policy for create, write CloudWatch logs Access"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
})
}

#IAM Policy attachment to IAM role : SQS policy
resource "aws_iam_policy_attachment" "policy_attachment_sqs" {
  name       = "policy_attachment_SQS"
  roles      = [aws_iam_role.Publisher_and_Reprovisioning_Lambdas_Role.name]
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}

#IAM Policy attachment to IAM role : cloudwatch policy
resource "aws_iam_policy_attachment" "policy_attachment_CWlogs" {
  name       = "policy_attachment_CWlogs"
  roles      = [aws_iam_role.Publisher_and_Reprovisioning_Lambdas_Role.name]
  policy_arn = aws_iam_policy.cloudwatchlogs_access_policy.arn
}


#Now, we need to create a ZIP file because aws_lambda_function needs the code to be stored in a ZIP file in order to upload to AWS.
data "archive_file" "publisher_lambda_archive" {
type        = "zip"
source_file  = "Publisher_Lambda.py"
output_path = "Publisher_Lambda.zip"
}

#Lambda function :
resource "aws_lambda_function" "publisher_lambda_func" {
filename                       = "Publisher_Lambda.zip"
function_name                  = "rbac-dev-feeder"
role                           = aws_iam_role.Publisher_and_Reprovisioning_Lambdas_Role.arn
handler                        = "index.handler"
runtime                        = "python3.8"
}

#Create lambda 2 : provisioning_lambda , lambda permissions-> lambda access sqs, s3  
#IAM Role creation for lambda 2: Role 2
resource "aws_iam_role" "provisioning_lambda_Role" {
name   = "rbac_provisioning_lambda_role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

#IAM Policy : S3 full Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_full_access_policy"
  description = "policy for read, write S3 Access"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${aws_s3_bucket.rbac_s3_bucket.arn}"
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            #The s3:*Object action uses a wildcard as part of the action name. The AllObjectActions statement allows the GetObject, DeleteObject, PutObject, and any other Amazon S3 action that ends with the word "Object".
            "Action": "s3:*Object", 
            "Resource": "${aws_s3_bucket.rbac_s3_bucket.arn}/*"
        }
    ]
})
}


# SQS IAM Policy attachment to IAM role
resource "aws_iam_policy_attachment" "SQS_policy_attachment" {
  name       = "sqs_policy_attachment"
  roles      = [aws_iam_role.provisioning_lambda_Role.name]
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}

#S3 IAM Policy attachment to IAM role
resource "aws_iam_policy_attachment" "S3_policy_attachment" {
  name       = "s3_policy_attachment"
  roles      = [aws_iam_role.provisioning_lambda_Role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

#Now, we need to create a ZIP file because aws_lambda_function needs the code to be stored in a ZIP file in order to upload to AWS.
data "archive_file" "provisioning_lambda_archive" {
type        = "zip"
source_file  = "Provisioning_Lambda.py"
output_path = "Provisioning_Lambda.zip"
}


#Lambda function :
resource "aws_lambda_function" "provisioning_lambda_func" {
filename                       = "Provisioning_Lambda.zip"
function_name                  = "rbac-dev-provisioning"
role                           = aws_iam_role.provisioning_lambda_Role.arn
handler                        = "index.handler"
runtime                        = "python3.8"
}

#Trigger from SQS to Provisioning lambda on any data passed to sqs from publisher lambda
# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.provisioning_lambda_func.arn
  batch_size       = "${var.batch_size}"
}

#Create lambda 3 : reprovisioning_lambda , lambda permissions
#Now, we need to create a ZIP file because aws_lambda_function needs the code to be stored in a ZIP file in order to upload to AWS.
data "archive_file" "reprovisioning_lambda_archive" {
type        = "zip"
source_file  = "Reprovisioning_Lambda.py"
output_path = "Reprovisioning_Lambda.zip"
}

#Lambda function :
resource "aws_lambda_function" "reprovisioning_lambda_func" {
filename                       = "Reprovisioning_Lambda.zip"
function_name                  = "rbac-dev-reprovisioning"
role                           = aws_iam_role.Publisher_and_Reprovisioning_Lambdas_Role.arn
handler                        = "index.handler"
runtime                        = "python3.8"
}


#Create SQS queue and DLQ (Dead Letter Queue)
resource "aws_sqs_queue" "sqs_queue" {
  name                      = "rbac-dev-provisioning-queue.fifo"
  fifo_queue                = true
  delay_seconds             = "${var.delay_seconds}"
  max_message_size          = "${var.max_message_size}"
  message_retention_seconds = "${var.message_retention_seconds}"
  receive_wait_time_seconds = "${var.receive_wait_time_seconds}"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = "${var.maxReceiveCount}"
  })
}

resource "aws_sqs_queue" "deadletter_queue" {
  name                        = "rbac-dev-provisioning-queue-dlq.fifo"
  fifo_queue                = true
  message_retention_seconds   = "${var.message_retention_seconds}"
  visibility_timeout_seconds  = "${var.visibility_timeout_seconds}"
}

#Create S3 Bucket
resource "aws_s3_bucket" "rbac_s3_bucket" {
  bucket = "rbac-businessrole-mappings-1"
}

resource "aws_s3_bucket_versioning" "Bucket_versioning" {
  bucket = aws_s3_bucket.rbac_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_access" {
  bucket = aws_s3_bucket.rbac_s3_bucket.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}





