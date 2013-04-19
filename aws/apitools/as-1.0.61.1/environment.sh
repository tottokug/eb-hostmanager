# Set AWS_AUTO_SCALING_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$AWS_AUTO_SCALING_HOME" ] && AWS_AUTO_SCALING_HOME="/opt/aws/apitools/as"
export AWS_AUTO_SCALING_HOME
