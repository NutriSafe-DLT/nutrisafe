CCNAME=nutrisafecc
FUNCTION="CreateProduct"
ARGS="PRO123"
CLI=cli.deoni.de


docker exec $CLI bash -c "peer chaincode query -C cheese -n '$CCNAME' -c '{\"Args\":[\"'$FUNCTION'\",\"'$ARGS'\"]}'"
