General information
Interaction is carried out via HTTPS using GET/POST/PUT methods. The API uses the REST architecture:

POST and PUT requests use JSON arguments;
GET requests work with query strings;
The API always returns a response in JSON format, regardless of the type of the request;
Request headers:

curl --request POST 'https://ecom.runpay.md/api/v2/invoices' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json'
Content-type: application/json is transmitted in the headers of all requests and responses;
Authorization: Bearer {token}is transmitted in the headers of all requests;
Idempotency-Key: {key_value} - request id (idempotency key);
In case of an error, the response contains code and the reason (code, message), and the answer may also contain sections with additional details.

An example of an error response:

{
  "code": "validation_error",
  "message": "One or many validation errors. See 'errors' list.",
  "errors": [
    "Specify required MerchantId value."
  ]
}
In requests, mandatory parameters are highlighted in bold.

Request authentication
Requests must be transmitted via a secure protocol (https). Base service address: https://ecom.runpay.md

The following methods of request authentication are supported:

Bearer: The token for the site can be generated in the Merchant's Personal Account. Must add to the Authorization header of each request.
Data types
The following data types are used in the requests:

Strings (string)
Numbers with a fractional part (numeric)
Dates (date). ISO 8601 format is used for the information transmission in the requests.
A three-letter code according to ISO 4217 is used to encode currencies.

Working with lists
Loading lists (payments, refunds, etc.) is made page by page: if there is a pointer to the next page (cursor) in the response, you must request the next part of data. To do this, repeat the request and add a cursor value to the list of parameters.

Payments
Payment link
POST /api/v2/invoices

Request example:

curl --request POST 'https://ecom.runpay.md/api/v2/invoices' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--data-raw '{
  "merchantId": "cf128151-127b-44ed-bde5-26c531cad20d",
  "invoice": {
    "description": "test payment",
    "params": {
      "BT_USR": "34"
    }
  },
  "amount": {
    "value": 10.50,
    "currency": "MDL"
  },
  "paymentMethod": "BankCard"   
}'
Request:

Parameter	Type	Description
merchantId	string	Merchant identification
dualMode	bool	DMS payments flag (false by default)
testMode	bool	Test payments flag (false by default)
tokenization		Tokenization details
invoice		Invoice details
amount		Amount
paymentMethod	string	Payment method
protocol		Protocol parameters
customer		Customer data
Response example:

{
  "paymentId": "12769",
  "url": "https://ecom.runpay.md/cpay/a62beecb68c84778b2424294f635b370"  
}
Response:

Parameter	Type	Description
paymentId	string	Payment identification
url	string	Payment page url, where the user should be redirected for making a payment
Creating a payment
POST /api/v2/payments

Request example:

curl --request POST 'https://ecom.runpay.md/api/v2/payments' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--data-raw '{
  "merchantId": "cf128151-127b-44ed-bde5-26c531cad20d",
  "invoice": {
    "description": "test payment",
    "params": {
      "BT_USR": "34"
    }
  },
  "amount": {
    "value": 10.50,
    "currency": "MDL"
  },
  "paymentData": {
    "paymentMethod": "BankCard",        
    "card": {
      "pan": "4**********0540",
      "expiry": "10/22",
      "cvc": "***"
    }
  }
}'
Request:

Parameter	Type	Description
merchantId	string	Merchant identification
dualMode	bool	DMS payments flag (false by default)
testMode	bool	Test payments flag (false by default)
tokenization		Tokenization details
invoice		Invoice details
amount		Amount
paymentData		Payment data
protocol		Protocol parameters
customer		Customer data
device		User device details
Parameters for making a payment depend on the payment method chosen.

Response example:

{
  "id": "12769",
  "created":"2021-09-01T08:20:00Z",
  "testMode": false,
  "status": "Confirmation",
  "resultCode": "Success",
  "merchantId": "96e809e9-8bce-40fd-86cb-d34db39b4668",
  "amount": {
    "value": 10.5000,
    "currency": "MDL"
  },
  "invoice": {
    "description": "test payment",
    "params": {
      "BT_USR": "34"
    }
  },
  "paymentData": {
    "paymentMethod": "BankCard"
  },
  "confirmation": {
    "type": "ThreeDSv1",
    "acsUrl": "https://ecom.runpay.md/acs/pareq",
    "PAReq": "eJxVUtuO0...v4BOrji7g=="
  }
}
Response
Parameter	Type	Description
id	string	Payment identification
created	date	Payment date
testMode	bool	Test payments flag
status	string	Payment status
resultCode	string	Result code
message	string	Authorization result description
merchantId	string	Merchant identification
invoice		Invoice details
amount		Amount
customer		Customer data
paymentData		Payment data
confirmation		Payment confirmation method
paymentToken		Payment token data
Additional confirmation (or several confirmations) may be required during the payment process.

Payment confirmation in the external system
Parameter	Type	Description
type	string	Confirmation type External
paymentUrl	string	Payment confirmation address to redirect the user
universalLink	bool	Payment link attribute
instruction	string	Payment instruction
Payment confirmation with a one-time code
Parameter	Type	Description
type	string	Confirmation type SmsOtp
maskedPhone	string	Telephone number that receives the confirmation code
3DS Method scenario
Parameter	Type	Description
type	string	Confirmation type ThreeDSMethod
methodUrl	string	ACS page address to pass the scenario
transactionId	string	Transaction authentication ID
3DS Challenge Flow scenario
Parameter	Type	Description
type	string	Confirmation type ThreeDSChallenge
acsUrl	string	ACS page address to pass the scenario
creq	string	Challenge request
3DS v1 scenario
Parameter	Type	Description
type	string	Confirmation type ThreeDSv1
acsUrl	string	ACS page address to pass the scenario
PAReq	string	Payer Authentication request
Payment completion
PUT /api/v2/payments/{id}/complete

Request example:

curl --request PUT 'https://ecom.runpay.md/api/v2/payments/12769/complete' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Content-Type: application/json' \
--data-raw '{
  "PARes": "eJx7v3u...IxsAwA="  
}'
Request:

Parameter	Type	Description
id	string	Payment identification
code	string	Confirmation code
threeDSCompInd	string	3DS Method complete indicator
cres	string	Challenge response
PARes	string	Payer Authentication response
In response service returns the payment details.

Payment capture
PUT /api/v2/payments/{id}/confirm

Request example:

curl --request PUT 'https://ecom.runpay.md/api/v2/payments/12769/confirm' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Content-Type: application/json' \
--data-raw '{
  "amount": {
    "value": 10.50,
    "currency": "MDL"
  }
}'
Request:

Parameter	Type	Description
id	string	Payment identification
amount		Amount
If the request is successful, the service returns an empty response with HTTP status 200.

Payment cancellation
PUT /api/v2/payments/{id}/cancel

Request example:

curl --request PUT 'https://ecom.runpay.md/api/v2/payments/12769/cancel' \
--header 'Authorization: Bearer QdvdwiXKFm='
If the request is successful, the service returns an empty response with HTTP status 200.

Getting payment details
GET /api/v2/payments/{id}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/payments/12769' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
Request:

Parameter	Type	Description
id	string	Payment identification
The service returns payment details in the response.

List of payments
GET /api/v2/payments?merchantId={merchantId}&start={start}&end={end}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/payments?merchantId=cf128151-127b-44ed-bde5-26c531cad20d&start=2021-08-01T06:00:00Z&end=2021-08-01T06:30:00Z'  \
--header 'Authorization: Bearer QdvdwiXKFm=' \
Request:

Parameter	Type	Description
merchantId	string	Merchant identification
start	date	Period starts
end	date	Period ends
Response example:

{
  "items": [
    {
      "id": "9755",
      "status": "Settled",
      "created":"2021-08-01T06:15:00Z",
      "merchantId": "96e809e9-8bce-40fd-86cb-d34db39b4668",
      "amount": {
        "value": 10.0000,
        "currency": "MDL"
      },
      "invoice": {
        "description": "test"
      },
      "paymentData": {
        "paymentMethod": "BankCard",
        "paymentInstrumentTitle": "410000XXXXXXX0000"
      }
    }
  ]
}
Response:

Parameter	Type	Description
id	string	Payment identification
created	date	Payment date
status	string	Payment status
merchantId	string	Merchant identification
invoice		Invoice details
amount		Amount
paymentData		Payment data
Refunds
Creating a refund
POST /api/v2/refunds

Request example:

curl --request POST 'https://ecom.runpay.md/api/v2/refunds' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--data-raw '{
  "paymentId": "12870",
  "amount": {
    "value": 5.5,
    "currency": "MDL"
  }
}'
Request:

Parameter	Type	Description
paymentId	string	Payment identification
amount		Refund amount
Response example:

{
  "id": "1276",
  "created": "2021-10-01T06:23:02.273Z",
  "status": "Pending",
  "paymentId": "12870",
  "amount": {
    "value": 5.5,
    "currency": "MDL"
  }
}
Response
Parameter	Type	Description
id	string	Refund identification
created	date	Refund date
paymentId	string	Payment identification
amount		Refund amount
status	string	Refund status
resultCode	string	Result code
Refund details
GET /api/v2/refunds/{id}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/refunds/1276' \
--header 'Authorization: Bearer QdvdwiXKFm='
Request:

Parameter	Type	Description
id	string	Refund identification
The service returns the refund details in the response.

List of refunds
GET /api/v2/refunds?merchantId={merchantId}&start={start}&end={end}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/refunds?merchantId=cf128151-127b-44ed-bde5-26c531cad20d&start=2021-08-01T06:00:00Z&end=2021-08-01T06:30:00Z'  \
--header 'Authorization: Bearer QdvdwiXKFm=' \
Request:

Parameter	Type	Description
merchantId	string	Merchant identification
start	date	Period starts
end	date	Period ends
Response example:

{
  "items": [
    {
      "id": "1276",
      "created": "2021-10-01T06:23:02.273Z",
      "status": "Pending",
      "paymentId": "12870",
      "amount": {
        "value": 5.5,
        "currency": "MDL"
      }
    }
  ]
}
Response:

Parameter	Type	Description
id	string	Refund identification
created	date	Refund date
paymentId	string	Payment identification
amount		Refund amount
status	string	Refund status
Payment tokens
Tokenization link
POST /api/v2/tokenization

Request example:

curl --request POST 'https://ecom.runpay.md/api/v2/tokenization' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--data-raw '{
  "merchantId": "cf128151-127b-44ed-bde5-26c531cad20d",
  "type": "recurring",
  "purpose": "Test subscription"
  "paymentMethod": "bankcard",
  "customer": {
    "account": "47733000003"
  }   
}'
Request:

Parameter	Type	Description
merchantId	string	Merchant ID
testMode	bool	Test mode flag (false by default)
type	string	Token type (recurring)
purpose	string	Subscription description
paymentMethod	string	Payment method
callbackUrl	string	Token status notification url
returnUrl	string	Url for customer return page
customer		Customer data
Response example:

{
  "tokenId": "8cd9991b47ab42018f0bb56ca0fbdba0",
  "url": "https://ecom.runpay.md/cpay/tokenization/f3da06b158924a6c8da280a8b49c2996"  
}
Response:

Parameter	Type	Description
tokenId	string	Token ID
url	string	Tokenization url for customer to complete scenario
Create token request
POST /api/v2/paymenttokens

Request example:

curl --request POST 'https://ecom.runpay.md/api/v2/paymenttokens' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--data-raw '{
  "merchantId": "cf128151-127b-44ed-bde5-26c531cad20d",
  "type": "recurring",
  "purpose": "Test subscription"
  "paymentData": {
    "paymentMethod": "sbp"
  },
  "customer": {
    "account": "47733000003"
  }   
}'
Request:

Parameter	Type	Description
merchantId	string	Merchant ID
testMode	bool	Test mode flag (false by default)
type	string	Token type (recurring)
purpose	string	Subscription description
paymentData		Payment data
protocol		Protocol parameters
customer		Customer data
Response example:

{
    "id": "8cd9991b47ab42018f0bb56ca0fbdba0",
    "status": "Created",
    "confirmation": {
        "type": "External",
        "universalLink": true,
        "paymentUrl": "https://ecom.runpay.md/cpay/mock/sbp/subscription/8cd9991b47ab42018f0bb56ca0fbdba0"
    }
}
Response
Parameter	Type	Description
id	string	Token identifier
status	string	Token status (Active / Revoked)
title	string	Display name
expires	date	Token expire date
cardInfo		Card BIN details
confirmation		Additional confirmation
Additional confirmation (or several confirmations) may be required during the process.

Confirmation in the external system
Parameter	Type	Description
type	string	Confirmation type External
paymentUrl	string	Confirmation address to redirect the user
universalLink	bool	Payment link attribute
instruction	string	Payment instruction
Token details
GET /api/v2/paymenttokens/{id}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/paymenttokens/8cd9991b47ab42018f0bb56ca0fbdba0' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
Request:

Parameter	Type	Description
id	string	Token identifier
In response service returns the token details.

Token revocation
PUT /api/v2/paymenttokens/{id}/revoke

Request example:

curl --request PUT 'https://ecom.runpay.md/api/v2/paymenttokens/8cd9991b47ab42018f0bb56ca0fbdba0/revoke' \
--header 'Authorization: Bearer QdvdwiXKFm='
Request:

Parameter	Type	Description
id	string	Token identifier
HTTP 200 status shows the successful completion of the request.

Stickers
Sticker registration
POST /api/v2/stickers

Request example:

curl --request POST 'https://ecom.runpay.md/api/v2/stickers' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Idempotency-Key: 86cf125c' \
--header 'Content-Type: application/json' \
--data-raw '{
  "merchantId": "cf128151-127b-44ed-bde5-26c531cad20d",
  "stickerType": "Sbp",
  "productCode": "product-1234",
  "paymentPurpose": "Payment for the product",
  "description": "Product #1234",
  "amount": {
    "value": 39.90,
    "currency": "RUB"
  }
}'
Request:

Parameter	Type	Description
merchantId	string	Merchant identification
stickerType	string	Sticker type (example, Sbp)
cashlink	bool	Cashlink mode
description	string	Sticker description
productCode	string	Product code
paymentPurpose	string	Payment purpose
amount		Amount
callbackUrl	string	Url for payment notification
Response example:

{
  "id": "24cc565dea08",
  "stickerType": "Sbp",
  "productCode": "product-1234",
  "paymentPurpose": "Payment for the product",
  "description": "Product #1234",
  "amount": {
    "value": 39.90,
    "currency": "RUB"
  },
  "status": "Active",
  "payload": "https://qr.nspk.ru/AS****G0?type=01&sum=3990&cur=RUB&crc=ZZZZ"
}
Response
Parameter	Type	Description
id	string	Sticker identification
stickerType	string	Sticker type
cashlink	bool	Cashlink mode
productCode	string	Product code
paymentPurpose	string	Payment purpose
description	string	Sticker description
amount		Amount
status	string	Sticker status
payload	string	Content (payment link)
Sticker activation / deactivation
PUT /api/v2/stickers/{id}

Request example:

curl --request PUT 'https://ecom.runpay.md/api/v2/stickers/24cc565dea08' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
--header 'Content-Type: application/json' \
--data-raw '{
  "active": true
}'
Request:

Parameter	Type	Description
id	string	Sticker identification
active	bool	Sticker status
HTTP 200 status shows the successful completion of the request.

Getting sticker details
GET /api/v2/stickers/{id}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/stickers/24cc565dea08' \
--header 'Authorization: Bearer QdvdwiXKFm=' \
Request:

Parameter	Type	Description
id	string	Sticker identification
The service returns sticker details in the response.

List of stickers
GET /api/v2/stickers?merchantId={merchantId}

Request example:

curl --request GET 'https://ecom.runpay.md/api/v2/stickers?merchantId=cf128151-127b-44ed-bde5-26c531cad20d'  \
--header 'Authorization: Bearer QdvdwiXKFm=' \
Request:

Parameter	Type	Description
merchantId	string	Merchant identification
Response example:

{
  "items": [
    {
      "id": "24cc565dea08",
      "stickerType": "Sbp",
      "productCode": "product-1234",
      "paymentPurpose": "Payment for the product",
      "description": "Product #1234",
      "amount": {
        "value": 39.90,
        "currency": "RUB"
      },
      "status": "Active",
      "payload": "https://qr.nspk.ru/AS****G0?type=01&sum=3990&cur=RUB&crc=ZZZZ"
    }
  ]
}
Ответ:

Parameter	Type	Description
items	array	List of stickers
Notifications
Payment status
POST {callbackUrl}

Request example:

curl --request POST 'https://merchant-site.com/payments/result' \
--header 'Content-Type: application/json' \
--data-raw '{
  "id": "12769",
  "created":"2021-09-01T08:20:00Z",
  "testMode": false,
  "status": "Settled",
  "merchantId": "96e809e9-8bce-40fd-86cb-d34db39b4668",
  "amount": {
    "value": 10.5000,
    "currency": "MDL"
  },
  "invoice": {
    "description": "test payment",
    "params": {
      "BT_USR": "34"
    }
  },
  "paymentData": {
    "paymentMethod": "BankCard",
    "paymentInstrumentTitle": "410000XXXXXXX0000"
  }
}'
Request:

Parameter	Type	Description
id	string	Payment identification
created	date	Payment date
testMode	bool	Test payments flag
status	string	Payment status
merchantId	string	Merchant identification
invoice		Invoice details
amount		Amount
paymentData		Payment data
Payment token status
POST {callbackUrl}

Request example:

curl --request POST 'https://merchant-site.com/tokens/result' \
--header 'Content-Type: application/json' \
--data-raw '{
  "id": "8cd9991b47ab42018f0bb56ca0fbdba0",
  "status": "Active",
  "title": "410000XXXXXX0001",
  "expires": "2022-10-31T23:59:59Z"
}'
Request:

Parameter	Type	Description
id	string	Token identifier
status	string	Token status (Active / Revoked)
title	string	Display name
expires	date	Token expire date
Payment methods
Alias	Name
bankcard	Bank card
runpay	RunPay
webmoney	WebMoney
mia	MIA Instant Payments
Codes and dictionaries
Error codes
Code	Description
validation_error	Incorrect request format
not_authorized	Not enough user rights for the operation
idempotency_key_violation	Idempotency key violation
invalid_operation	Request is rejected
payment_token_revoked	Payment token is revoked
payment_token_blocked	Payment token is locked out
Payment status
Code	Description
Authorized	Payment is authorized
Settled	Payment is settled
Cancelled	Payment is cancelled
Rejected	Payment is rejected
Confirmation	Additional confirmation is required
Pending	Payment is pending
Refund status
Code	Description
Success	Refund is successful
Rejected	Refund is rejected
Pending	Refund is pending
Authorization code
Code	Description
TransactionDeclined	Transaction authorization is declined
IssuerUnavailable	Issuer is not available
RejectedByFraud	Rejected by fraud monitoring
InvalidAmount	Invalid amount
InvalidAccount	Incorrect card number / card does not exist
BlockedAccount	Card is blocked (lost)
OperationNotAllowed	Operation is not allowed
InsufficientFunds	Insufficient funds
ExpiredAccount	Expired card date / incorrect card date
PaymentLimitExceeded	Payment limit exceeded
PaymentCountExceeded	Payment count exceeded
CardNotEnrolled	Card is not enrolled for 3DS
ThreeDSecureFailed	3DS authentication is not passed
CancelledByUser	User cancelled the payment
PaymentExpired	Payment expired