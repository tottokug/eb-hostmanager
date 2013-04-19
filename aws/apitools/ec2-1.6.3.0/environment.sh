# Set EC2_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$EC2_HOME" ] && EC2_HOME="/opt/aws/apitools/ec2"
export EC2_HOME
