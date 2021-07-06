mysql -h token-game-db-t2-small-v1.cjgcqwhurzri.us-east-1.rds.amazonaws.com -u colinTradolf2 --ssl-mode=DISABLED -p




select
	(SELECT platform_id from users WHERE users.id = balances.token_brand_id) as twitterIdFrom,
users.platform_id as twitterIdTo, '' as twitterIdThirdParty, balances.balance as amountOrId,  balances.platform_handle, 0 as decimalPlaceLocation from balances left join users on users.id=balances.platform_handle_id WHERE token_brand='@cryptoraves' limit 5;

#json object
SELECT CONCAT(
    '[',
    GROUP_CONCAT(CONCAT(
    	'{"twitterIdFrom":"', IFNULL((SELECT platform_id FROM users WHERE users.id = transfers.user_from_id),''), '"',
    	',"twitterIdTo":"', IFNULL((SELECT platform_id FROM users WHERE users.id = transfers.user_to_id),''), '"',
    	',"twitterIdThirdParty":"',IFNULL((SELECT platform_id FROM users WHERE users.id = transfers.token_brand_id),''), '"',
    	',"amountOrId":"', IFNULL(amount,''), '"',
    	',"decimalPlaceLocation":"', 0, '"',
    	',"tweetId":"', IFNULL((SELECT platform_content_id FROM requests where requests.id = request_id),''), '"',
    	',"twitterHandleFrom":"',IFNULL(user_from,''), '"',
    	',"twitterHandleTo":"', IFNULL(user_to,''), '"',
    	',"ticker":""',
    	',"_platformName":"', 'twitter', '"',
    	',"_txnType":"', IFNULL(IF(user_from='LAUNCH', 'launch', 'transfer'),''), '"',
    	',"_fromImgUrl":"',IFNULL((select image_url FROM users where users.id=user_from_id),''), '"',
    	',"L1Address":"', IFNULL((select eth_address FROM users where users.id=user_from_id),''), '"}'
    )),
    ']'
)
FROM transfers;


select
	(SELECT platform_id FROM users WHERE users.id = transfers.user_from_id) as twitterIdFrom,
	(SELECT platform_id FROM users WHERE users.id = transfers.user_to_id) as twitterIdTo,
	(SELECT platform_id FROM users WHERE users.id = transfers.token_brand_id) as twitterIdThirdParty,
	amount as amountOrId, 0 as decimalPlaceLocation,
	(SELECT platform_content_id FROM requests where requests.id = request_id) as tweetId,

	user_from as twitterHandleFrom, user_to as twitterHandleTo, '' as ticker, 'twitter' as _platformName,
	IF(user_from='LAUNCH', 'launch', 'transfer') as _txnType,
	(select image_url FROM users where users.id=user_from_id) as _fromImgUrl,
	(select eth_address FROM users where users.id=user_from_id) as L1Address
	FROM transfers
	limit 5;





echo "SELECT CONCAT( '{\"twitterIdFrom\":\"', IFNULL((SELECT platform_id FROM users WHERE users.id = transfers.user_from_id),''), '\"', ',\"twitterIdTo\":\"', IFNULL((SELECT platform_id FROM users WHERE users.id = transfers.user_to_id),''), '\"', ',\"twitterIdThirdParty\":\"',IFNULL((SELECT platform_id FROM users WHERE users.id = transfers.token_brand_id),''), '\"', ',\"amountOrId\":\"', IFNULL(amount,''), '\"', ',\"decimalPlaceLocation\":\"', 0, '\"', ',\"tweetId\":\"', IFNULL((SELECT platform_content_id FROM requests where requests.id = request_id),''), '\"', ',\"twitterHandleFrom\":\"',IFNULL(user_from,''), '\"', ',\"twitterHandleTo\":\"', IFNULL(user_to,''), '\"', ',\"ticker\":\"\"', ',\"_platformName\":\"', 'twitter', '\"', ',\"_txnType\":\"', IFNULL(IF(user_from='LAUNCH', 'launch', 'transfer'),''), '\"', ',\"_fromImgUrl\":\"',IFNULL((select image_url FROM users where users.id=user_from_id),''), '\"', ',\"L1Address\":\"', IFNULL((select eth_address FROM users where users.id=user_from_id),''), '\"},' ) FROM transfers" | mysql --host=token-game-db-t2-small-v1.cjgcqwhurzri.us-east-1.rds.amazonaws.com --user=colinTradolf2 --ssl-mode=DISABLED -p token_game_plasma > /tmp/realUserData.json

sed -i '1,1s/^/[ /'  /tmp/realUserData.json
echo ']' >> /tmp/realUserData.json


mysqldump --column-statistics=0  --host=token-game-db-t2-small-v1.cjgcqwhurzri.us-east-1.rds.amazonaws.com -u colinTradolf2 --ssl-mode=DISABLED -p token_game_plasma > ~/Downloads/dbexport.sql
