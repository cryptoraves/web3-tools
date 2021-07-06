mysql -h token-game-db-t2-small-v1.cjgcqwhurzri.us-east-1.rds.amazonaws.com -u colinTradolf2 --ssl-mode=DISABLED -p




select 
	(SELECT platform_id from users WHERE users.id = balances.token_brand_id) as twitterIdFrom,
users.platform_id as twitterIdTo, '' as twitterIdThirdParty, balances.balance as amountOrId,  balances.platform_handle, 0 as decimalPlaceLocation from balances left join users on users.id=balances.platform_handle_id WHERE token_brand='@cryptoraves' limit 5;


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
	
	
	
	
	
echo "use token_game_plasma; select (SELECT platform_id FROM users WHERE users.id = transfers.user_from_id) as twitterIdFrom,(SELECT platform_id FROM users WHERE users.id = transfers.user_to_id) as twitterIdTo,(SELECT platform_id FROM users WHERE users.id = transfers.token_brand_id) as twitterIdThirdParty,amount as amountOrId, 0 as decimalPlaceLocation, (SELECT platform_content_id FROM requests where requests.id = request_id) as tweetId,	user_from as twitterHandleFrom, user_to as twitterHandleTo, '' as ticker, 'twitter' as _platformName,IF(user_from='LAUNCH', 'launch', 'transfer') as _txnType,(select image_url FROM users where users.id=user_from_id) as _fromImgUrl,	(select eth_address FROM users where users.id=user_from_id) as L1Address FROM transfers" | mysql --host=token-game-db-t2-small-v1.cjgcqwhurzri.us-east-1.rds.amazonaws.com --user=colinTradolf2 --ssl-mode=DISABLED -p > /tmp/realUserData.csv




mysqldump --host=token-game-db-t2-small-v1.cjgcqwhurzri.us-east-1.rds.amazonaws.com -u colinTradolf2 --ssl-mode=DISABLED -p token_game_plasma > ~/Downloads/dbexport.sql
