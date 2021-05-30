/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

struct MockIdentityResponse {

    static let json: String = """
{
    "id": "https://login.salesforce.com/id/00Di0000000bcJ3EEI/005i00000018PdaAEE",
    "asserted_user": true,
    "user_id": "005i00000018PdaAEE",
    "organization_id": "00Di0000000bcJ3EEI",
    "username": "mvannostrand@vandelayind.com",
    "nick_name": "mvann",
    "display_name": "Martin Van Nostrand",
    "email": "mvannostrand@vandelayind.com",
    "email_verified": true,
    "first_name": "Martin",
    "last_name": "Van Nostrand",
    "timezone": "America/Los_Angeles",
    "photos": {
        "picture": "https://theplayground-dev-ed--c.na161.content.force.com/profilephoto/7291Y000000ENO1/F",
        "thumbnail": "https://theplayground-dev-ed--c.na161.content.force.com/profilephoto/7291Y000000ENO1/T"
    },
    "addr_street": "123 Mission Street",
    "addr_city": "San Francisco",
    "addr_state": "CA",
    "addr_country": "US",
    "addr_zip": null,
    "mobile_phone": null,
    "mobile_phone_verified": false,
    "is_lightning_login_user": false,
    "status": {
        "created_date": null,
        "body": null
    },
    "urls": {
        "enterprise": "https://theplayground-dev-ed.my.salesforce.com/services/Soap/c/{version}/00Di0000000bcK3",
        "metadata": "https://theplayground-dev-ed.my.salesforce.com/services/Soap/m/{version}/00Di0000000bcK3",
        "partner": "https://theplayground-dev-ed.my.salesforce.com/services/Soap/u/{version}/00Di0000000bcK3",
        "rest": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/",
        "sobjects": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/sobjects/",
        "search": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/search/",
        "query": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/query/",
        "recent": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/recent/",
        "tooling_soap": "https://theplayground-dev-ed.my.salesforce.com/services/Soap/T/{version}/00Di0000000bcK3",
        "tooling_rest": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/tooling/",
        "profile": "https://theplayground-dev-ed.my.salesforce.com/005i00000016PdaAAE",
        "feeds": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/chatter/feeds",
        "groups": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/chatter/groups",
        "users": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/chatter/users",
        "feed_items": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/chatter/feed-items",
        "feed_elements": "https://theplayground-dev-ed.my.salesforce.com/services/data/v{version}/chatter/feed-elements",
        "custom_domain": "https://theplayground-dev-ed.my.salesforce.com"
    },
    "active": true,
    "user_type": "STANDARD",
    "language": "en_US",
    "locale": "en_US",
    "utcOffset": -28800000,
    "last_modified_date": "2020-09-01T23:59:16Z"
}
"""

}
