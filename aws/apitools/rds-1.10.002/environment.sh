# Set AWS_RDS_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$AWS_RDS_HOME" ] && AWS_RDS_HOME="/opt/aws/apitools/rds"
export AWS_RDS_HOME
