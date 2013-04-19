#Set EC2_AMITOOL_HOME.  Called from /etc/profile.d/aws-product-common
[ -z "$EC2_AMITOOL_HOME" ] && EC2_AMITOOL_HOME="/opt/aws/amitools/ec2"
export EC2_AMITOOL_HOME
