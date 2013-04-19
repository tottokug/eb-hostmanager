# Set AWS_CLOUDWATCH_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$AWS_CLOUDWATCH_HOME" ] && AWS_CLOUDWATCH_HOME="/opt/aws/apitools/mon"
export AWS_CLOUDWATCH_HOME
