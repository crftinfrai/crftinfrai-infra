resource "aws_lambda_function" "lambda" {
  function_name = var.name
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  filename      = var.filename
  memory_size   = var.memory_size
  timeout       = var.timeout
  architectures = [var.architecture]
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}
