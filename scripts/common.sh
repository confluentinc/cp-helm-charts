if [ -t 1 ] ; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  RS='\033[0m' # reset to no color
else
  RED=''
  GREEN=''
  BLUE=''
  RS=''
fi
