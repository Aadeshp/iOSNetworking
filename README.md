# iOSNetworking
iOS/OSX Networking Library

# How To Use
1. Init Using Either:

```objective-c
APNetworking *network = [[APNetworking alloc] init];
APNetworking *network = [[APNetworking alloc] initWithBaseUrl:@"BASE URL"];
```

2. Making A Request:

```objective-c
[network request:(HTTPRequest)
          urlext:@"URL EXTENSION"
          params:Either as NSString: @"param1=value1&param2=value2..." or NSDictionary @{ "param1": "value1", "param2": "value2"... }
            mime:(MimeType)
 completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) { ... }];
 ```

- Example of Completion Blocks

```objective-c
void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      //Display Error Here
    }
    
    //Get Response Text
    if (data) {
      NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; //Or use whatever encoding needed
      //Do Whatever You Want With The Response Text
    }
}

//If You Want To Use A Variable Inside AND Outside the block, Do the following

__block VariableType VariableName;  //__block allows you to use the variable inside and outside a block
```

- HTTPRequest ENUM
```
HTTPRequestPost
HTTPRequestGet
HTTPRequestPatch
HTTPRequestPut
HTTPRequestDelete
```
- MimeType ENUM:
```
MimeTypeJson (application/json)
MimeTypeHtml (text/html)
MimeTypeFormUrlEncoded (application/x-www-form-urlencoded)
```


