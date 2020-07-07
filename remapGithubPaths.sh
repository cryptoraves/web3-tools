rel_path=$(dirname $(realpath $0))

find . -type f -name "*.sol" -exec sed -i'' -e 's#https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master#'${HOME}'/www/openzeppelin-contracts#g' {} +
