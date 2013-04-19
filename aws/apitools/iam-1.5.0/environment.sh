# Set AWS_IAM_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$AWS_IAM_HOME" ] && AWS_IAM_HOME="/opt/aws/apitools/iam"
export AWS_IAM_HOME
