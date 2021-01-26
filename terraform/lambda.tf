data "aws_iam_policy_document" "lambda_edge" {
  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.lambda_edge.arn]
  }
}

module "lambda_edge_role" {
  source      = "./module/iam"
  name        = "${var.app_name}-${terraform.workspace}-lambda-edge"
  identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
  policy      = data.aws_iam_policy_document.lambda_edge.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = module.lambda_edge_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "basic_auth" {
  type        = "zip"
  source_dir  = "lambda/${var.lambda_function[terraform.workspace]}"
  output_path = "dist/basicAuth.zip"
}

resource "aws_lambda_function" "basic_auth" {
  provider         = aws.virginia
  filename         = data.archive_file.basic_auth.output_path
  function_name    = "${var.app_name}-${terraform.workspace}-basic-auth"
  role             = module.lambda_edge_role.iam_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.basic_auth.output_base64sha256
  runtime          = "nodejs10.x"

  publish = true

  memory_size = 128
  timeout     = 3
}
