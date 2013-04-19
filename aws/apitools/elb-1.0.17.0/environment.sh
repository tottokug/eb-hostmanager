# Set AWS_ELB_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$AWS_ELB_HOME" ] && AWS_ELB_HOME="/opt/aws/apitools/elb"
export AWS_ELB_HOME
