CCNAME=nutrisafecc
FUNCTION="CreateProduct"
ARGS="PRO123"
CLI=cli.deoni.de

# Parameters for organization and container
while getopts "h?l:a:f:n:i:q" opt; do
  case "$opt" in
  a)
    ARGS=$OPTARG
    ;;
  f)
    FUNCTION=$OPTARG
    ;;
  n)
    CCNAME=$OPTARG
    ;;
  i)
    CLI=$OPTARG
    ;;
  esac
done

docker exec $CLI bash -c "peer chaincode query -C cheese -n '$CCNAME' -c '{\"Args\":[\"'$FUNCTION'\",\"'$ARGS'\"]}'"
